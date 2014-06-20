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
   names  = { "1:gen", "2:www", "3:im", "4:mutt", "5:aud", 6, 7, 8, 9 },
   layout = { layouts[1], layouts[3], layouts[1], layouts[3], layouts[1],
              layouts[3], layouts[3], layouts[3], layouts[3]
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
   { "quit", awesome.quit }
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
mycpu = lain.widgets.cpu({
    timeout = 4,
    settings = function()
        widget:set_markup("cpu:" .. cpu_now.usage)
    end
})

mymem = lain.widgets.mem({
    timeout = 4,
    settings = function()
        widget:set_markup("mem:" .. mem_now.used)
    end
})

-- Textclock
mytextclock = awful.widget.textclock("%a, %d/%m/%y, %H:%M")

-- calendar
lain.widgets.calendar:attach(mytextclock, { cal = 'cal -m', font = 'Inconsolata', font_size = 10 })

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


for s = 1, screen.count() do
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
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    if s == 2 then
       right_layout:add(spacer)
       right_layout:add(mycpu)
       right_layout:add(spacer)
       right_layout:add(mymem)
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

end

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
    awful.key({ modkey,           }, "s",
        function ()
            mymainmenu:show({keygrabber=true})
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
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ altkey, 'Control' }, "l", function () awful.util.spawn('slimlock') end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    -- awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    -- awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    -- awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    -- awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1) naughty.notify({ title = 'Master', text = tostring(awful.tag.getnmaster()), timeout = 1 }) end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1) naughty.notify({ title = 'Master', text = tostring(awful.tag.getnmaster()), timeout = 1 }) end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1) naughty.notify({ title = 'Columns', text = tostring(awful.tag.getncol()), timeout = 1 }) end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1) naughty.notify({ title = 'Columns', text = tostring(awful.tag.getncol()), timeout = 1 }) end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Multiple monitors
    -- awful.key({ modkey,           }, "o",      function(c) awful.client.movetoscreen(c,c.screen-1) end ),
    -- awful.key({ modkey,           }, "p",      function(c) awful.client.movetoscreen(c,c.screen+1) end ),

    -- volume control with amixer
    awful.key({}, "XF86AudioLowerVolume", function ()
        awful.util.spawn_with_shell("amixer set Master 5%-")
    end),

    awful.key({}, "XF86AudioRaiseVolume", function ()
        awful.util.spawn("amixer set Master 5%+")
    end),

    awful.key({}, "XF86AudioMute", function()
        if is_mute then
            is_mute = false
            awful.util.spawn_with_shell("amixer set Master unmute")
        else
            is_mute = true
            awful.util.spawn_with_shell("amixer set Master mute")
        end
    end),

    -- Prompt
    -- Run applications with dmenu
    awful.key({ modkey },            "a",     function ()
        awful.util.spawn("dmenu_run -l 5 -i -p 'Run:' -nb '" ..
        beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal ..
        "' -sb '" .. beautiful.bg_focus ..
        "' -sf '" .. beautiful.fg_focus .. "'")
      end),

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
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
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
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
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
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
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
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Firefox" }, except = { role = 'browser' },
      properties = { floating = true } },
    { rule = { class = "Thunderbird" }, except = { role = '3pane' },
      properties = { floating = true } }
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
--
--
client.size_hints_honor = false
--

runonce.run("redshift-gtk -l 52.7:21.6 -t 5700:4300 -g 0.8 -m randr")
runonce.run("yaudtray")
runonce.run("clipit")
runonce.run("qasmixer -t")

require("run_local")
