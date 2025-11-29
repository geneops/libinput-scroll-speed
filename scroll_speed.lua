local CURVE = {
    { 0.0, 0.15 },
    { 2.0, 0.3 },
    { 5.0, 0.5 },
    { 15.0, 0.7 },
}

local last_us = 0

function get_multiplier(speed)
    if speed <= CURVE[1][1] then
        return CURVE[1][2]
    end

    for i = 1, #CURVE - 1 do
        local p1 = CURVE[i]
        local p2 = CURVE[i+1]

        if speed >= p1[1] and speed <= p2[1] then
            local t = (speed - p1[1]) / (p2[1] - p1[1])
            return p1[2] + t * (p2[2] - p1[2])
        end
    end

    return CURVE[#CURVE][2]
end

function round(num)
    if num >= 0 then return math.floor(num + 0.5) else return math.ceil(num - 0.5) end
end

function handle_frame(device, frame, timestamp)
    local modified = false
    local dt_ms = (timestamp - last_us) / 1000.0

    if dt_ms > 200 then dt_ms = 200 end
    if dt_ms < 1 then dt_ms = 1 end
    last_us = timestamp

    for _, event in ipairs(frame) do
        if event.usage == evdev.REL_WHEEL_HI_RES or
           event.usage == evdev.REL_H_WHEEL_HI_RES then

            local speed = math.abs(event.value) / dt_ms
            local factor = get_multiplier(speed)
            event.value = round(event.value * factor)
            modified = true

        elseif event.usage == evdev.REL_WHEEL or
               event.usage == evdev.REL_H_WHEEL then

            local speed = (math.abs(event.value) * 120) / dt_ms
            local factor = get_multiplier(speed)
            local newVal = round(event.value * factor)

            if newVal == 0 and event.value ~= 0 then
                if event.value > 0 then newVal = 1 else newVal = -1 end
            end
            event.value = newVal
            modified = true
        end
    end

    if modified then return frame end
    return nil
end

function new_device(device)
    local props = device:udev_properties()

    if props["ID_INPUT_MOUSE"] then
        libinput:log_info("Applying custom scroll curve to generic mouse: " .. device:name())
        device:connect("evdev-frame", handle_frame)
    end
end

local version = libinput:register({1})
if version == 1 then
    libinput:connect("new-evdev-device", new_device)
end
