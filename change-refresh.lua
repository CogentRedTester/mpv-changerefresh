--[[
    This script uses nircmd to change the refresh rate of the display that the mpv window is currently open in
    This was written because I could not get autospeedwin to work :(
]]--

local mp = require "mp"
local msg = require "mp.msg"
local utils = require "mp.utils"
local opts = require "mp.options"

--options available through --script-opts=changerefresh-[option]=value
--all of these options can be changed at runtime using profiles, the script will automatically update
local o = {
    --the location of nircmd.exe, tries to use the system path by default
    nircmd = "nircmd",

    --list of valid refresh rates, separated by semicolon, listed in ascending order
    --by adding a hyphen after a number you can set a custom display rate for that specific video rate:
    --  "23;24;25-50;60"  Will set the display to 50fps for 25fps videos
    --this whitelist also applies when attempting to revert the display, so include that rate in the list
    --nircmd only seems to work with integers, DO NOT use the full refresh rate, i.e. 23.976
    rates = "23;24;25;29;30;50;59;60",

    --change refresh automatically on startup
    auto = false,

    --duration (in seconds) of the pause when changing display modes
    --set to zero to disable video pausing
    pause = 3,

    --colour bit depth to send to nircmd
    --you shouldn't need to change this, but it's here just in case
    bdepth = "32",

    --set whether to use the estimated fps or the container fps
    --see https://mpv.io/manual/master/#command-interface-container-fps for details
    estimated_fps = false,

    -- --automatically detect monitor resolution when changing refresh rates
    -- --will use this resolution when reverting changes
    -- detect_display_resolution = true,

    -- --default width and height to use when changing & reverting the refresh rate
    -- --ony used if detect_display_resolution is false
    -- original_width = 1920,
    -- original_height = 1080,

    -- --if this value is set to anything but zero to script will always to to revert to this rate
    -- --this rate bypasses the usual rates whitelist, so make sure it is valid
    -- --the actual original rate will be ignored
    -- original_rate = 0,

    --if enabled, this mode sets the monitor to the specified dimensions when the resolution of the video is greater than or equal to the threshold
    --if less than the threshold the monitor will be set to the default shown above, or to the current resolution
    --this feature is only really useful if you don't want to be upscaling video to UHD, but still want to play UHD files in native resolution
    UHD_adaptive = false,
    UHD_threshold = 1440,
    UHD_width = 3840,
    UHD_height = 2160,

    --set whether to output status messages to the osd
    osd_output = true
}

opts.read_options(o, "change-refresh", function() end)


local function co_run(fn, ...)
    return coroutine.wrap(fn)(...)
end

local function sleep(n)
    local co = coroutine.running()
    mp.add_timeout(n, function()
        coroutine.resume(co)
    end)
    coroutine.yield()
end

local function execute_asyc(args)
    local co = coroutine.running()
    mp.command_native_async({
        name = "subprocess",
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
        args = args
    }, function(_, result)
        coroutine.resume(co, result)
    end)

    local cmd = coroutine.yield()
    if cmd.status ~= 0 then
        msg.error(cmd.stderr)
    end
    return cmd
end

local function execute(args)
    local cmd = mp.command_native({
        name = "subprocess",
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
        args = args
    })

    if cmd.status ~= 0 then
        msg.error(cmd.stderr)
    end
    return cmd
end
