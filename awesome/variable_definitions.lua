-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
config_dir = awful.util.getdir("config")
beautiful.init(config_dir .. "/current_theme/theme.lua")

beautiful.border_focus  = "#ff0000"
beautiful.border_normal = "#c0c0c0"
beautiful.cpu_icon      = config_dir .. "/icons/cpu.png"
beautiful.mem_icon      = config_dir .. "/icons/mem.png"
beautiful.fs_icon       = config_dir .. "/icons/fs.png"
beautiful.netup_icon    = config_dir .. "/icons/net_up.png"
beautiful.netdown_icon  = config_dir .. "/icons/net_down.png"
beautiful.bg_normal     = "#5b7fa6"
beautiful.bg_systray    = beautiful.bg_normal



-- This is used later as the default terminal and editor to run.
terminal = "konsole"
-- terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
