--[[
   Starbreaker Awesome WM config 0.1
   github.com/demifiend

   Based on...

   Multicolor Awesome WM config 2.0 
   github.com/copycat-killer                              

   Modified by aajjbb:
   github.com/aajjbb
--]]

-- {{{ Required libraries
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local drop      = require("scratchdrop")
local lain      = require("lain")
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
					title = "Oops, there were errors during startup!",
					text = awesome.startup_errors })
end

do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
							 if in_error then return end
							 in_error = true

							 naughty.notify({ preset = naughty.config.presets.critical,
											  title = "Oops, an error happened!",
											  text = err })
							 in_error = false
   end)
end
-- }}}

-- {{{ Autostart applications
function run_once(cmd)
   findme = cmd
   firstspace = cmd:find(" ")
   if firstspace then
	  findme = cmd:sub(0, firstspace-1)
   end
   awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

run_once("")

function spawn_once(command, class, tag)
   -- create move callback
   local callback
   callback = function(c)
	  if c.instance == class then
		 awful.client.movetotag(tag, c)
		 client.disconnect_signal("manage", callback)
	  end
   end
   client.connect_signal("manage", callback)
   -- now check if not already running!
   local findme = command
   local firstspace = findme:find(" ")
   if firstspace then
	  findme = findme:sub(0, firstspace-1)
   end
   -- finally run it
   awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. command .. ")")
end


-- }}}

-- {{{ Variable definitions
-- localization
os.setlocale(os.getenv("LANG"))

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/starbreaker/theme.lua")

-- common
modkey     = "Mod4"
altkey     = "Mod1"
terminal   = "xterm" or "urxvtc"
editor     = "emacs" or "vim"
editor_cmd = terminal .. " -e " .. editor

-- user defineid
sub = "subl3"
irc = "hexchat"
term = "xterm"
text_editor = "emacs"
browser = "google-chrome-stable"
browser2 = "firefox"
gui_editor = "subl3"
graphics = "gimp"
mail = "thunderbird"
word_processor = "libreoffice --writer"
im = "pidgin"
music = "ario"
video = "vlc"
files = "caja --no-desktop"
screenshot = "scrot -q 100 '%Y-%m-%d-%k-%M-%S_$wx$h.png' -e 'mv $f ~/Pictures/shots/'"

local layouts = {
   awful.layout.suit.max,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.spiral,
   awful.layout.suit.tile.magnifier,
}
-- }}}

-- {{{ Tags

tags = {
   names = { 
	  "1]Web",
	  "2]Emacs",
	  "3]Term",
	  "4]Files",
	  "5]Mail",
	  "6]Chat",
	  "7]Music",
	  "8]Game",
	  "9]Other"
   },
   layout = {  
	  layouts[1], 
	  layouts[1], 
	  layouts[1], 
	  layouts[1], 
	  layouts[1], 
	  layouts[1], 
	  layouts[1],
	  layouts[1],
	  layouts[1]
   }
}
for s = 1, screen.count() do
   -- Each screen has its own tag table.
   tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
   for s = 1, screen.count() do
	  gears.wallpaper.maximized(beautiful.wallpaper, s, true)
   end
end

--[[

-- configuration - edit to your liking
wp_index = 1
wp_timeout  = 10
wp_path = "/home/lawks/.config/awesome/themes/starbreaker/wp/"
wp_files = { "wp1.jpg", "wp2.jpg", "wp3.jpg" }
 
-- setup the timer
wp_timer = timer { timeout = wp_timeout }
wp_timer:connect_signal("timeout", function()
 
  -- set wallpaper to current index for all screens
  for s = 1, screen.count() do
    gears.wallpaper.maximized(wp_path .. wp_files[wp_index], s, true)
  end
 
  -- stop the timer (we don't need multiple instances running at the same time)
  wp_timer:stop()
 
  -- get next random index
  wp_index = math.random( 1, #wp_files)
 
  --restart the timer
  wp_timer.timeout = wp_timeout
  wp_timer:start()
end)
 
-- initial start when rc.lua is first run
wp_timer:start()

--]]

-- }}}

-- {{{ Freedesktop Menu
freedesktopmenu = require("menugen").build_menu()
starbreakermenu = {
   { "Without Bloodshed", withoutbloodshed },
   { "The Blackened Phoenix", blackenedphoenix },
   { "Silent Clarion", silentclarion }
}
webprojectmenu = {
   { "matthewgraybosch.com", matthewgraybosch_com },
   { "starbreakerseries.com", starbreakerseries_com }
}
awesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "config", sub .. " ~/.config/awesome/rc.lua" },
   { ".Xresources", sub .. " ~/.Xresources" },
   { ".xprofile", sub .. " ~/.xprofile" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}
mymainmenu = awful.menu.new({ items = {
								-- { "starbreaker", starbreakermenu },
								-- { "web projects", webprojectmenu },
								 { "Web Browser", browser},
								 { "Text Editor", text_editor },
								 { "Terminal", term },
								 { "Files", files },
								 { "E-Mail", mail },
								 { "IRC", irc },
								 { "Music Player", music },
								 { "Video Player", video },
								 { "Apps", freedesktopmenu },
								 { "Awesome", awesomemenu }
},
							  theme = { height = 16, width = 150 }})
-- }}}

-- {{{ Wibox
markup = lain.util.markup

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = awful.widget.textclock(markup("#7788af", "%d %B %Y ") .. markup("#de5e1e", " %I:%M %p "))

-- Calendar
lain.widgets.calendar:attach(mytextclock, { 
								font_size = 10,
								font = "Source Code Pro Medium" 
})

-- Weather
weathericon = wibox.widget.imagebox(beautiful.widget_weather)
yawn = lain.widgets.yawn(444148, {
							settings = function()
							   widget:set_markup(markup("#eca4c4", forecast:lower() .. " @ " .. units .. "°C "))
							end
})

-- fs
fsicon = wibox.widget.imagebox(beautiful.widget_fs)
fswidget = lain.widgets.fs({
	  settings  = function()
		 widget:set_markup(markup("#80d9d8", fs_now.used .. "% "))
	  end
})

-- CPU
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpuwidget = lain.widgets.cpu({
	  settings = function()
		 widget:set_markup(markup("#e33a6e", cpu_now.usage .. "% "))
	  end
})

-- Coretemp
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidget = lain.widgets.temp({
	  settings = function()
		 widget:set_markup(markup("#f1af5f", coretemp_now .. "°C "))
	  end
})

-- Battery
baticon = wibox.widget.imagebox(beautiful.widget_batt)
batwidget = lain.widgets.bat({
	  timeout = 0.1,
	  battery = "BAT0",
	  notify = "on",
	  
	  settings = function()
		 if bat_now.perc == "N/A" then
			bat_now.perc = "AC "
		 else
			bat_now.perc = bat_now.perc .. "% "
		 end
		 widget:set_text(bat_now.perc .. bat_now.status)
	  end
})

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
	  timeout = 0.2,
	  channel = "Master",
	  settings = function()
		 if volume_now.status == "off" then
            volume_now.level = volume_now.level .. "M"
		 end
		 
		 widget:set_markup(markup("#7493d2", volume_now.level .. "% "))
	  end
})
volumewidget:buttons(awful.util.table.join(
						awful.button({ }, 4, function () awful.util.spawn("amixer set Master 2%+") end),
						awful.button({ }, 5, function () awful.util.spawn("amixer set Master 2%-") end)
))

-- Net
neticon = wibox.widget.imagebox(beautiful.widget_weather)

netssid = wibox.widget.textbox()

netdownicon = wibox.widget.imagebox(beautiful.widget_netdown)
netdowninfo = wibox.widget.textbox()

netupicon = wibox.widget.imagebox(beautiful.widget_netup)

netupinfo = lain.widgets.net({
	  settings = function()
		 if iface ~= "network off" and
			string.match(yawn.widget._layout.text, "N/A")
		 then
			yawn.fetch_weather()
		 end

		 file_helper = io.popen("iwgetid -r")
		 ssid = file_helper:read("*all")
		 
		 if (ssid == "") then
			ssid = "Not connected"
		 end
		 
		 widget:set_markup(markup("#e54c62", net_now.sent .. " "))
		 netssid:set_markup(markup("#cc66ff", ssid .. " "))
		 netdowninfo:set_markup(markup("#87af5f", net_now.received .. " "))
	  end
})

-- MEM
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
	  settings = function()
		 widget:set_markup(markup("#e0da37", mem_now.used .. "M "))
	  end
})

-- cmus widget
cmusicon = wibox.widget.imagebox()

cmuswidget = lain.widgets.abase({
	  cmd = "cmus-remote -Q",
	  settings = function()
		 cmus_now = {
            state   = "N/A",
            artist  = "N/A",
            title   = "N/A",
            album   = "N/A"
		 }

		 for w in string.gmatch(output, "(.-)tag") do
            a, b = w:match("(%w+) (.-)\n")
            cmus_now[a] = b
		 end

		 -- customize here
		 widget:set_markup(markup("#e54c62", cmus_now.artist) .. " - " .. markup("#b2b2b2", cmus_now.title) .. "  ")
	  end
})

-- Spacer
spacer = wibox.widget.textbox(" ")

-- }}}

-- {{{ Layout

-- Create a wibox for each screen and add it
mywibox = {}
mybottomwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
   awful.button({ }, 1, awful.tag.viewonly),
   awful.button({ modkey }, 1, awful.client.movetotag),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, awful.client.toggletag),
   awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
   awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
		 if c == client.focus then
			c.minimized = true
		 else
			-- Without this, the following
			-- :isvisible() makes no sense
			c.minimized = false
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

   -- Create the upper wibox
   mywibox[s] = awful.wibox({ position = "top", screen = s, height = 24 })
   --border_width = 0, height =  20 })

   -- Widgets that are aligned to the upper left
   local left_layout = wibox.layout.fixed.horizontal()
   archicon = wibox.widget.imagebox(beautiful.widget_arch)
   left_layout:add(archicon)
   left_layout:add(mytaglist[s])
   left_layout:add(mypromptbox[s])

   -- Widgets that are aligned to the upper right
   local right_layout = wibox.layout.fixed.horizontal()
   --right_layout:add(cmuswidget)
   --right_layout:add(cmusicon)
   right_layout:add(netdownicon)
   right_layout:add(netdowninfo)
   right_layout:add(netupicon)
   right_layout:add(netupinfo)
   right_layout:add(neticon)
   right_layout:add(netssid)
   right_layout:add(volicon)
   right_layout:add(volumewidget)
   right_layout:add(memicon)
   right_layout:add(memwidget)
   right_layout:add(cpuicon)
   right_layout:add(cpuwidget)
   right_layout:add(fsicon)
   right_layout:add(fswidget)
   right_layout:add(tempicon)
   right_layout:add(tempwidget)
   right_layout:add(baticon)
   right_layout:add(batwidget)
   right_layout:add(clockicon)
   right_layout:add(mytextclock)

   -- Now bring it all together (with the tasklist in the middle)
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   --layout:set_middle(mytasklist[s])
   layout:set_right(right_layout)

   mywibox[s]:set_widget(layout)

   -- Create the bottom wibox
   mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, border_width = 0, height = 24 })
   
   -- Widgets that are aligned to the bottom left
   bottom_left_layout = wibox.layout.fixed.horizontal()
   if s == 1 then bottom_left_layout:add(wibox.widget.systray()) end

   -- Widgets that are aligned to the bottom right
   bottom_right_layout = wibox.layout.fixed.horizontal()
   bottom_right_layout:add(mylayoutbox[s])

   -- Now bring it all together (with the tasklist in the middle)
   bottom_layout = wibox.layout.align.horizontal()
   bottom_layout:set_left(bottom_left_layout)
   bottom_layout:set_middle(mytasklist[s])
   bottom_layout:set_right(bottom_right_layout)
   mybottomwibox[s]:set_widget(bottom_layout)
end
-- }}}

-- {{{ Mouse Bindings
root.buttons(awful.util.table.join(
				awful.button({ }, 3, function () mymainmenu:toggle() end),
				awful.button({ }, 4, awful.tag.viewnext),
				awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
   -- Take a screenshot
   awful.key({}, "Print", function () 
		 awful.util.spawn_with_shell(screenshot)
   end),

   -- Tag browsing
   awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
   awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
   awful.key({ modkey }, "Escape", awful.tag.history.restore),

   -- Non-empty tag browsing
   awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end),
   awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end),

   -- Default client focus
   awful.key({ altkey }, "k",
	  function ()
		 awful.client.focus.byidx( 1)
		 if client.focus then client.focus:raise() end
   end),
   awful.key({ altkey }, "j",
	  function ()
		 awful.client.focus.byidx(-1)
		 if client.focus then client.focus:raise() end
   end),

   -- By direction client focus
   awful.key({ modkey }, "j",
	  function()
		 awful.client.focus.bydirection("down")
		 if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey }, "k",
	  function()
		 awful.client.focus.bydirection("up")
		 if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey }, "h",
	  function()
		 awful.client.focus.bydirection("left")
		 if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey }, "l",
	  function()
		 awful.client.focus.bydirection("right")
		 if client.focus then client.focus:raise() end
   end),

   -- Show Menu
   awful.key({ modkey }, "w",
	  function ()
		 mymainmenu:show({ keygrabber = true })
   end),

   -- Show/Hide Wibox
   awful.key({ modkey }, "b", function ()
		 mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
		 mybottomwibox[mouse.screen].visible = not mybottomwibox[mouse.screen].visible
   end),

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
   awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
   awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
   awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
   awful.key({ modkey,           }, "Tab",
	  function ()
		 awful.client.focus.history.previous()
		 if client.focus then
			client.focus:raise()
		 end
   end),
   awful.key({ altkey, "Shift"   }, "l",      function () awful.tag.incmwfact( 0.05)     end),
   awful.key({ altkey, "Shift"   }, "h",      function () awful.tag.incmwfact(-0.05)     end),
   awful.key({ modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)       end),
   awful.key({ modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)       end),
   awful.key({ modkey, "Control" }, "l",      function () awful.tag.incncol(-1)          end),
   awful.key({ modkey, "Control" }, "h",      function () awful.tag.incncol( 1)          end),
   awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1)  end),
   awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1)  end),
   awful.key({ modkey, "Control" }, "n",      awful.client.restore),

   -- Standard program
   awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
   awful.key({ modkey, "Control" }, "r",      awesome.restart),
   awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

   -- Dropdown terminal
   awful.key({ modkey,	          }, "z",      function () drop(terminal) end),

   -- ALSA volume control	

   awful.key({ }, "XF86AudioRaiseVolume",    function () awful.util.spawn("amixer set Master 2%+") end),
   awful.key({ }, "XF86AudioLowerVolume",    function () awful.util.spawn("amixer set Master 2%-") end),
   awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer set Master toggle") end),

   awful.key({ }, "XF86AudioPlay",    function () awful.util.spawn("cmus-remote -u") end),
   awful.key({ }, "XF86AudioPrev",    function () awful.util.spawn("cmus-remote -r") end),
   awful.key({ }, "XF86AudioNext",    function () awful.util.spawn("cmus-remote -n") end),
   
   -- end

   -- MPD control
   awful.key({ altkey, "Control" }, "Up",
	  function ()
		 awful.util.spawn_with_shell("mpc toggle || ncmpc toggle || pms toggle")
		 mpdwidget.update()
   end),
   awful.key({ altkey, "Control" }, "Down",
	  function ()
		 awful.util.spawn_with_shell("mpc stop || ncmpc stop || pms stop")
		 mpdwidget.update()
   end),
   awful.key({ altkey, "Control" }, "Left",
	  function ()
		 awful.util.spawn_with_shell("mpc prev || ncmpc prev || pms prev")
		 mpdwidget.update()
   end),
   awful.key({ altkey, "Control" }, "Right",
	  function ()
		 awful.util.spawn_with_shell("mpc next || ncmpc next || pms next")
		 mpdwidget.update()
   end),

   -- Copy to clipboard
   awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

   -- User programs
   awful.key({ modkey }, "q", function () awful.util.spawn(browser) end),
   awful.key({ modkey }, "i", function () awful.util.spawn(browser2) end),
   awful.key({ modkey }, "s", function () awful.util.spawn(gui_editor) end),
   awful.key({ modkey }, "g", function () awful.util.spawn(graphics) end),

   -- Prompt
   awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
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

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
   globalkeys = awful.util.table.join(globalkeys,
									  awful.key({ modkey }, "#" .. i + 9,
										 function ()
											local screen = mouse.screen
											local tag = awful.tag.gettags(screen)[i]
											if tag then
											   awful.tag.viewonly(tag)
											end
									  end),
									  awful.key({ modkey, "Control" }, "#" .. i + 9,
										 function ()
											local screen = mouse.screen
											local tag = awful.tag.gettags(screen)[i]
											if tag then
											   awful.tag.viewtoggle(tag)
											end
									  end),
									  awful.key({ modkey, "Shift" }, "#" .. i + 9,
										 function ()
											local tag = awful.tag.gettags(client.focus.screen)[i]
											if client.focus and tag then
											   awful.client.movetotag(tag)
											end
									  end),
									  awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
										 function ()
											local tag = awful.tag.gettags(client.focus.screen)[i]
											if client.focus and tag then
											   awful.client.toggletag(tag)
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
	 properties = { 
		border_width = beautiful.border_width,
		border_color = beautiful.border_normal,
		focus = awful.client.focus.filter,
		keys = clientkeys,
		buttons = clientbuttons,
		size_hints_honor = false } },

   { rule = { class = "web" },
	 properties = { tag = tags[1][1] } },

   { rule = { class = "emacs" },
	 properties = { tag = tags[1][2] } },

   { rule = { class = "term" },
	 properties = { tag = tags[1][3] } },	

   { rule = { class = "doc" },
	 properties = { tag = tags[1][4] } },	
   
   { rule = { class = "mail" },
	 properties = { tag = tags[1][5] } },

   { rule = { class = "chat" },
	 properties = { tag = tags[1][6] } },

   { rule = { class = "skype" },
	 properties = { tag = tags[1][7] } },
   
   { rule = { class = "music" },
	 properties = { tag = tags[1][8] } },
   
   { rule = { class = "other" },
	 properties = { tag = tags[1][9] } },

   
   { rule = { class = "Gimp", role = "gimp-image-window" },
	 properties = { maximized_horizontal = true,
					maximized_vertical = true } },
}
-- }}}

-- {{{ Signals
-- signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
						 -- enable sloppy focus
						 c:connect_signal("mouse::enter", function(c)
											 if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
											 and awful.client.focus.filter(c) then
												client.focus = c
											 end
						 end)

						 if not startup and not c.size_hints.user_position
						 and not c.size_hints.program_position then
							awful.placement.no_overlap(c)
							awful.placement.no_offscreen(c)
						 end

						 local titlebars_enabled = false
						 if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
							-- buttons for the titlebar
							local buttons = awful.util.table.join(
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
							)

							-- widgets that are aligned to the right
							local right_layout = wibox.layout.fixed.horizontal()
							right_layout:add(awful.titlebar.widget.floatingbutton(c))
							right_layout:add(awful.titlebar.widget.maximizedbutton(c))
							right_layout:add(awful.titlebar.widget.stickybutton(c))
							right_layout:add(awful.titlebar.widget.ontopbutton(c))
							right_layout:add(awful.titlebar.widget.closebutton(c))

							-- the title goes in the middle
							local middle_layout = wibox.layout.flex.horizontal()
							local title = awful.titlebar.widget.titlewidget(c)
							title:set_align("center")
							middle_layout:add(title)
							middle_layout:buttons(buttons)

							-- now bring it all together
							local layout = wibox.layout.align.horizontal()
							layout:set_right(right_layout)
							layout:set_middle(middle_layout)

							awful.titlebar(c,{size=16}):set_widget(layout)
						 end
end)

-- No border for maximized clients
client.connect_signal("focus",
					  function(c)
						 if c.maximized_horizontal == true and c.maximized_vertical == true then
							c.border_color = beautiful.border_normal
						 else
							c.border_color = beautiful.border_focus
						 end
end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
														 local clients = awful.client.visible(s)
														 local layout  = awful.layout.getname(awful.layout.get(s))

														 if #clients > 0 then -- Fine grained borders and floaters control
															for _, c in pairs(clients) do -- Floaters always have borders
															   -- No borders with only one humanly visible client
															   if layout == "max" then
																  c.border_width = 0
															   elseif awful.client.floating.get(c) or layout == "floating" then
																  c.border_width = beautiful.border_width
															   elseif #clients == 1 then
																  clients[1].border_width = 0
																  if layout ~= "max" then
																	 awful.client.moveresize(0, 0, 2, 0, clients[1])
																  end
															   else
																  c.border_width = beautiful.border_width
															   end
															end
														 end
													 end)
end
-- }}}

awful.util.spawn_with_shell("xrdb -merge ~/.Xresources")

-- spawn_once("google-chrome-stable", "web", tags[1][4])
-- spawn_once("emacs-24.3", "emacs", tags[1][2])
-- spawn_once("xterm -name other", "other", tags[1][9])

