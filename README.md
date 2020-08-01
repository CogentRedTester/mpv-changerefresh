# change-refresh

This script uses nircmd (windows only) to change the refresh rate of the display that the mpv window is currently open in
This was written because I could not get autospeedwin to work :(

The script uses a hotkey by default, but can be setup to run on startup.

## Behaviour
When the script is activated it will automatically detect the refresh rate of the current video and attempt to change the display
to the closes rate on the whitelist. The script will keep track of the original refresh rate of the monitor and revert when either the
correct keybind is pressed, or when mpv exits. The original rate needs to be included on the whitelist and follows
custom rate rules (i.e. if the monitor was originally 25Hz and the whitelist contains "25-50", then it will revert to 50).

## Rate Whitelist
If the display does not support the specified resolution or refresh rate it will silently fail
If the video refresh rate does not match any on the whitelist it will pick the next highest.
If the video fps is higher than any on the whitelist it will pick the highest available
The whitelist is specified via the script-opt 'rates'. Valid rates are separated via semicolons, do not include spaces and list in ascending order.
    Example:    changerefresh-rates="23;24;30;60"

### Custom Rates
You can also set a custom display rate for individual video rates using a hyphen:
    Example:    changerefresh-rates="23;24;25-50;30;60"
This will change the display to 23, 24, and 30 fps when playing videos in those same rates, but will change the display to 50 fps when
playing videos in 25 Hz

## Monitor Detection
The script automatically detects which monitor the mpv window is currently loaded on, and will save the original resolution and rate to revert to.
The original resolution is found by quickly switching to and from fullscreen mode, but if the resolution of the monitor never changes then this
automatic check can be disabled and the dimensions manually set in the config file.

Note that if the mpv window is lying across multiple displays it may not save the original refresh rate of the correct display

## UHD Mode
The script will always use the current dimensions of the monitor when switching refresh rates,
however I have an UHD mode (option is UHD_adaptive) hardcoded to use a resolution of 3840x2160p for videos with a height of > 1440 pixels.
This will cause the display to switch to UHD for UHD video, and back to the previous resolution for any other video. This is only useful if your computer
can handle playing UHD files directly, but not upscaling to UHD.


## Keybinds
The keybind to switch refresh rates is f10 by default, but this can be changed by setting different script bindings in input.conf.
The keybinds, and their behaviour are as follows:

    f10         match-refresh       detects the video fps and attempts to change the monitor refresh
    Ctrl+f10    revert-refresh      revert the display to the original refresh rate
                toggle-fps-type     switch between using the estimated and specified fps for the video
                set-default-refresh set the current resolution/refresh as the default

## Script Messages
You can also send refresh change commands directly using script messages:
    script-message change-refresh [width] [height] [rate] [display]

Display stands for the display number (starting from 0) which is printed to the console when the display is changed.
Leaving out this argument will auto-detect the currently used monitor, like the usual behaviour.

These script messages completely bypass the whitelist and rate associations and are sent to nircmd directly, so make sure you send a valid integer.
They are also completely independant from the usual automatic reversion system, so you'll have to handle that yourself.


## Configuration
See `changerefresh.conf` for the full options list, this file can be placed into the script-opts folder inside the mpv config directory.