-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)

local function notify_error(title, text)
    -- Try dunstify first (more reliable, survives awesome restarts)
    awful.spawn.with_shell(string.format(
        "dunstify -u critical -t 0 '%s' '%s' 2>/dev/null || true",
        title:gsub("'", "'\\''"),
        text:gsub("'", "'\\''")
    ))

    -- Fallback to naughty in case dunst isn't running
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = title,
        text = text
    })
end

if awesome.startup_errors then
    notify_error("Oops, there were errors during startup!", awesome.startup_errors)
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        notify_error("Oops, an error happened!", tostring(err))

        in_error = false
    end)
end
-- }}}
