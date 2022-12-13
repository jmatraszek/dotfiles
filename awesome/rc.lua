-- Dependencies:
-- suckless-tools feh xlockmore

-- Standard awesome library
awful = require("awful")
require("awful.autofocus")
awful.rules = require("awful.rules")
local wibox = require("wibox")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
naughty = require("naughty")
local menubar = require("menubar")
local lain = require("lain")
runonce = require("runonce")

-- Load Debian menu entries
require("debian.menu")

require("error_handling")
require("variable_definitions")

-- Default modkey.
modkey = "Mod4"
altkey = 'Mod1'

require('layouts')

-- {{{ Tags
-- Define a tag table which hold all screen tags.
 tags = {
   names  = { " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 " },
   layout = { layouts[2], layouts[2], layouts[2], layouts[2], layouts[2],
              layouts[2], layouts[2], layouts[2], layouts[2]
 }}
 for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
 end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
mylayoutmenu = {
   { "floating", function () awful.layout.set(awful.layout.suit.floating) end },
   { "tile", function () awful.layout.set(awful.layout.suit.tile) end },
   { "right", function () awful.layout.set(awful.layout.suit.tile.right) end },
   { "bottom", function () awful.layout.set(awful.layout.suit.tile.bottom) end },
   { "top", function () awful.layout.set(awful.layout.suit.tile.top) end },
   { "fair", function () awful.layout.set(awful.layout.suit.fair) end },
   { "horizontal", function () awful.layout.set(awful.layout.suit.fair.horizontal) end },
   { "spiral", function () awful.layout.set(awful.layout.suit.spiral) end },
   { "dwindle", function () awful.layout.set(awful.layout.suit.spiral.dwindle) end },
   { "max", function () awful.layout.set(awful.layout.suit.max) end },
   { "fullscreen", function () awful.layout.set(awful.layout.suit.max.fullscreen) end },
   { "magnifier", function () awful.layout.set(awful.layout.suit.magnifier) end }
}

myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", "gvim " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "apps", debian.menu.Debian_menu.Debian },
                                    { "layouts", mylayoutmenu },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a some widgets
markup = lain.util.markup

-- Net
netdownicon = wibox.widget.imagebox(beautiful.netdown_icon)
--netdownicon.align = "middle"
netdowninfo = wibox.widget.textbox()
netupicon = wibox.widget.imagebox(beautiful.netup_icon)
                                netupicon.align = "middle"
netupinfo = lain.widget.net({
    settings = function()
        widget:set_markup(markup("#e54c62", net_now.sent .. " "))
        netdowninfo:set_markup(markup("#87af5f", net_now.received .. " "))
    end
})

-- CPU
cpuicon = wibox.widget.imagebox(beautiful.cpu_icon)
mycpu = lain.widget.cpu({
    timeout = 4,
    settings = function()
        widget:set_markup(markup("#e33a6e", cpu_now.usage .. "% "))
    end
})

-- TEMP
tempicon = wibox.widget.imagebox(theme.temp_icon)
temp = lain.widget.temp({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, "#f1af5f", coretemp_now .. "°C "))
    end
})

-- MEM
memicon = wibox.widget.imagebox(beautiful.mem_icon)
mymem = lain.widget.mem({
    timeout = 4,
    settings = function()
        widget:set_markup(markup("#e0da37", mem_now.used .. "M "))
    end
})

-- Notifications icon
notificationwidget = wibox.widget.textbox("")

-- Textclock
mytextclock = wibox.widget.textclock("%a, %d/%m/%y, %H:%M")

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))


require("widgets/brightness")
awful.screen.connect_for_each_screen(function(s)
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

     -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
    local spacer = wibox.widget.textbox(" | ")

    -- Create the wibox
    mywibox[s] = awful.wibar({ position = "top", screen = s })
    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(notificationwidget)
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if screen.count() == 1 then
       right_layout:add(netdownicon)
       right_layout:add(netdowninfo)
       right_layout:add(netupicon)
       right_layout:add(netupinfo.widget)
       right_layout:add(cpuicon)
       right_layout:add(mycpu.widget)
       right_layout:add(memicon)
       right_layout:add(mymem.widget)
       right_layout:add(tempicon)
       right_layout:add(temp.widget)
       right_layout:add(brightness_icon)
       -- right_layout:add(brightness_widget)
       right_layout:add(wibox.widget.systray())
    else
       if s.index == 1 then right_layout:add(wibox.widget.systray()) end
       if s.index == 2 then
          right_layout:add(netdownicon)
          right_layout:add(netdowninfo)
          right_layout:add(netupicon)
          right_layout:add(netupinfo.widget)
          right_layout:add(cpuicon)
          right_layout:add(mycpu.widget)
          right_layout:add(memicon)
          right_layout:add(mymem.widget)
          right_layout:add(tempicon)
          right_layout:add(temp.widget)
          right_layout:add(brightness_icon)
       end
    end
    right_layout:add(spacer)
    right_layout:add(mytextclock)
    right_layout:add(spacer)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end)

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    awful.key({ modkey,           }, "r",    function ()
                awful.prompt.run({ prompt = "Rename tab: ", text = awful.tag.selected().name, },
                mypromptbox[mouse.screen].widget,
                function (s)
                    awful.tag.selected().name = s
                end)
        end),
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey,           }, "w", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey,           }, "q", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "]", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey,           }, "[", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end),
    awful.key({ modkey,           }, "\\",     function () awful.spawn('alacritty') end),
    awful.key({ modkey,           }, "=",      function () awful.spawn('konsole') end),
    awful.key({ altkey, 'Control' }, "l",      function () awful.spawn('slimlock') end),
    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function ()
       awful.tag.incnmaster( 1) naughty.notify({ title = 'Master', text = tostring(awful.tag.getnmaster()), timeout = 1 })
    end),
    awful.key({ modkey, "Shift"   }, "l",     function ()
       awful.tag.incnmaster(-1) naughty.notify({ title = 'Master', text = tostring(awful.tag.getnmaster()), timeout = 1 })
    end),
    awful.key({ modkey, "Control" }, "h",     function ()
       awful.tag.incncol( 1) naughty.notify({ title = 'Columns', text = tostring(awful.tag.getncol()), timeout = 1 })
    end),
    awful.key({ modkey, "Control" }, "l",     function ()
       awful.tag.incncol(-1) naughty.notify({ title = 'Columns', text = tostring(awful.tag.getncol()), timeout = 1 })
    end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Shift"   }, "n",     function ()
       naughty.toggle()
       if naughty.is_suspended() then
          notificationwidget:set_text("Notifications: OFF ")
       else
          notificationwidget:set_text("")
       end
    end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- volume control with amixer
    awful.key({}, "XF86MonBrightnessUp", function ()
        awful.spawn("xbacklight -inc 5")
    end),

    awful.key({}, "XF86MonBrightnessDown", function ()
        awful.spawn("xbacklight -dec 5")
    end),

    awful.key({ modkey, }, "F1", function()
      awful.spawn("pamixer -t")
    end),

    awful.key({ modkey, }, "F2", function ()
        awful.spawn("pamixer -d 5")
    end),

    awful.key({ modkey, }, "F3", function ()
        awful.spawn("pamixer -i 5")
    end),

    awful.key({}, "XF86AudioLowerVolume", function ()
        awful.spawn("pamixer -d 5")
    end),

    awful.key({}, "XF86AudioRaiseVolume", function ()
        awful.spawn("pamixer -i 5")
    end),

    awful.key({}, "XF86AudioMute", function()
      awful.spawn("pamixer -t")
    end),

    -- Prompt
    -- Run applications with rofi
    awful.key({ modkey }, "a", function () awful.spawn("rofi -show run") end),

    -- Switch to a window with rofi
    awful.key({ modkey }, "w", function () awful.spawn("rofi -show run") end),

    -- Start SSH session with rofi in a new terminal window
    awful.key({ modkey }, "s", function () awful.spawn("rofi -show ssh -terminal alacritty") end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "f",       awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
local gears = require("gears")
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "kcalc" },
      properties = { floating = true } },
    { rule = { name = "florence" },
      properties = { floating = true } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Firefox" }, except = { role = 'browser' },
      properties = { floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

client.size_hints_honor = false

-- Slack notification fix
naughty.config.notify_callback = function(args)
  if args.appname == "Electron" then
    args.title = args.title:gsub("^New message from (.*)$", "%1")
    args.icon = nil
  end

  return args
end

runonce.run("lxqt-policykit-agent")
runonce.run("nm-applet")
runonce.run("qxkb")
runonce.run("redshift-gtk -l 52.7:21.6 -t 5700:4300 -g 0.8 -m randr")
runonce.run("udiskie --smart-tray --notify --no-automount")
runonce.run("clipit")
runonce.run("pasystray --notify=sink_default")
runonce.run("unclutter")
runonce.run("flameshot")

require("run_local")
