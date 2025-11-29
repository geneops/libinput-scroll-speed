# Libinput Scroll Speed Plugin

A Lua plugin for `libinput` to customize scroll wheel acceleration and deceleration. Designed for devices with high-resolution scroll wheels on Wayland.

This plugin intercepts scroll events and applies a configurable velocity curve, allowing for precision scrolling at low speeds while maintaining faster traversal at high speeds.

## Requirements

- libinput 1.29+
- Wayland compositor with plugin support enabled

## Installation

1. Create the plugin directory:

```
sudo mkdir -p /etc/libinput/plugins
```

2. Copy the script:

```
sudo cp scroll_speed.lua /etc/libinput/plugins/
```

3. Restart the session (logout/login or reboot) to load the plugin.

## Configuration

Edit the configuration file to adjust the acceleration curve:

```
sudo nano /etc/libinput/plugins/scroll_speed.lua
```

Modify the `CURVE` table to define speed thresholds and multipliers `{ speed, multiplier }`:

```
local CURVE = {
    { 0.0, 0.15 },  -- 0.0 units/ms -> 0.15x speed
    { 2.0, 0.3 },   -- 2.0 units/ms -> 0.30x speed
    { 5.0, 0.5 },   -- 5.0 units/ms -> 0.50x speed
    { 15.0, 0.7 },  -- 15.0+ units/ms -> 0.70x speed (Max)
}
```

## Troubleshooting

Verify the plugin is loaded correctly:

```
sudo libinput debug-events --enable-plugins --verbose
```

Ensure the line `Acceleration Scroll modifier attached` appears in the output.
