-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/current_theme/theme.lua")
beautiful.border_focus = "#ff0000"
beautiful.border_normal = "#c0c0c0"

-- This is used later as the default terminal and editor to run.
terminal = "konsole"
-- terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
