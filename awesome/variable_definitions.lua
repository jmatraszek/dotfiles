-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers

config_dir = awful.util.getdir("config")
-- beautiful.init(config_dir .. "/current_theme/theme.lua")
beautiful.init(config_dir .. "/themes/jsky/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty -e 'tmux'"
-- terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
