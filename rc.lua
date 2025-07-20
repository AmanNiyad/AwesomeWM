pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local my_utils = require("my_modules/my_utils")
local lain = require("lain")
local capslock = require("my_modules/capslock")
local nextthing = require("my_modules/nextthing")
local cpu_widget = require("my_modules/cpu_widget")
local mem_widget = require("my_modules/mem_widget")
local net_widget = require("my_modules/network_widget")
local sound_widget = require("my_modules/sound-widget")
local mic_widget = require("my_modules/mic_widget")
local naughty = require("naughty")
local dpi = require("beautiful").xresources.apply_dpi
local hotkeys_popup = require("awful.hotkeys_popup")

-- debug stuff if needed
local printmore = false

require("awful.hotkeys_popup.keys")
require("awful.autofocus")

beautiful.hotkeys_font = "IosevkaTerm NerdFont Regular 12"
beautiful.hotkeys_description_font = "IosevkaTerm NerdFont Regular 10"
beautiful.hotkeys_bg = "#1e1e2e"
beautiful.hotkeys_fg = "#f8f8f2"
beautiful.hotkeys_modifiers_fg = "#ffb86c"
beautiful.hotkeys_border_color = "#bd93f9"
beautiful.hotkeys_border_width = 2
beautiful.hotkeys_shape = gears.shape.rounded_rect

hostname = io.popen("uname -n"):read()

-- Theme initialize
beautiful.init("/home/aman/.config/awesome/my_modules/my_theme.lua")

-- Error handling
dofile("/home/aman/.config/awesome/my_modules/rc_errorhandling.lua")
-- Functions definition
dofile("/home/aman/.config/awesome/my_modules/rc_functions.lua")
-- Tags definition
dofile("/home/aman/.config/awesome/my_modules/rc_tags.lua")
-- Volume/Brightness OSD notifications
dofile("/home/aman/.config/awesome/my_modules/rc_fn_actions.lua") -- Needs work!!!

-------------------- Client Keys --------------------

clientkeys = gears.table.join(

	awful.key({ win }, "d", function()
		awful.tag.incmwfact(0.01)
	end, { description = "Increase master width factor", group = "Layout" }),

	awful.key({ win }, "a", function()
		awful.tag.incmwfact(-0.01)
	end, { description = "Decrease master width factor", group = "Layout" }),

	awful.key({ win }, "s", function()
		awful.client.incwfact(-0.01)
	end, { description = "Decrease client height", group = "Layout" }),

	awful.key({ win }, "w", function()
		awful.client.incwfact(0.01)
	end, { description = "Increase client height", group = "Layout" }),

	-- Quit window

	awful.key({ win, "Shift" }, "c", function(c)
		c:kill()
	end, { description = "Close focused window", group = "Client" }),

	-- Swap master

	awful.key({ win }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "Swap with master window", group = "Client" }),

	-- Movement and expand

	awful.key({ ctrl, win }, "Right", function(c)
		move_or_expand(c, "expand", "right")
	end, { description = "Expand client to right", group = "Movement" }),

	awful.key({ ctrl, win }, "Left", function(c)
		move_or_expand(c, "expand", "left")
	end, { description = "Expand window to left", group = "Movement" }),

	awful.key({ ctrl, win }, "Down", function(c)
		move_or_expand(c, "expand", "down")
	end, { description = "Expand window downward", group = "Movement" }),

	awful.key({ ctrl, win }, "Up", function(c)
		move_or_expand(c, "expand", "up")
	end, { description = "Expand window upward", group = "Movement" }),

	-- Focus movement

	awful.key({ win }, "Right", function(c)
		switch_focus_without_mouse(c, "right", printmore)
	end, { description = "Focus right window", group = "Movement" }),

	awful.key({ win }, "Left", function(c)
		switch_focus_without_mouse(c, "left", printmore)
	end, { description = "Focus left window", group = "Movement" }),

	awful.key({ win }, "Down", function(c)
		if c.sticky then
			awful.client.focus.history.previous()
		else
			awful.client.focus.bydirection("down")
		end
	end, { description = "Focus bottom window or previous sticky", group = "Movement" }),

	awful.key({ win }, "Up", function(c)
		local cls = client.get()
		local stickies = {}
		for _, c in ipairs(cls) do
			if c.sticky then
				table.insert(stickies, c)
			end
		end
		if my_utils.table_length(stickies) == 0 then
			awful.client.focus.bydirection("up")
		else
			awful.client.focus.history.previous()
		end
	end, { description = "Focus top window or previous sticky", group = "Movement" }),

	-- Other client actions

	awful.key({ win }, "z", function(c)
		c.minimized = true
	end, { description = "Minimize client", group = "Client" }),

	awful.key({ ctrl, alt }, "s", function(c)
		suspend_toggle(c)
	end, { description = "Suspend focused window", group = "Client" }),

	awful.key({ ctrl, alt }, "w", function(c)
		float_toggle(c)
	end, { description = "Shrink and stick window on top", group = "Client" }),

	awful.key({ ctrl, alt }, "f", function(c)
		c.fullscreen = not c.fullscreen
	end, { description = "Fullscreen focused window", group = "Client" }),

	awful.key({ ctrl, alt, "Shift" }, "s", function(c)
		sticky_toggle(c)
	end, { description = "Sticky toggle for window", group = "Client" }),

	awful.key({ win }, "Escape", function(c)
		hide_stickies()
	end, { description = "Hide sticky windows to bottom right", group = "Client" })
)

my_systray = wibox.widget.systray()
my_systray:set_base_size(dpi(24))

function set_keys_after_screen_new(clientkeys, globalkeys, printmore)
	if screen:count() > 1 then
		clientkeys = gears.table.join(
			clientkeys,
			keydoc({ win, "Shift" }, "Left", "Move window to screen on the left", "Screen", function(c)
				c:move_to_screen(c.screen.index - 1)
			end),
			keydoc({ win, "Shift" }, "Right", "Move window to screen on right", "Screen", function(c)
				c:move_to_screen(c.screen.index + 1)
			end)
		)
	end

	-------------------- Tag switching --------------------
	globalkeys = gears.table.join(
		globalkeys,

		-- Tag switching

		awful.key({ win }, "#10", function()
			switch_to_tag("Term", printmore)
		end, { description = "Switch to tag 1 (Term)", group = "Tag" }),

		awful.key({ win }, "#11", function()
			switch_to_tag("Web", printmore)
		end, { description = "Switch to tag 2 (Web)", group = "Tag" }),

		awful.key({ win }, "#12", function()
			switch_to_tag("Mail", printmore)
		end, { description = "Switch to tag 3 (Mail)", group = "Tag" }),

		awful.key({ win }, "#13", function()
			switch_to_tag("Misc", printmore)
		end, { description = "Switch to tag 4 (Misc)", group = "Tag" }),

		-- Moving client to tag

		awful.key({ win, "Shift" }, "#10", function()
			move_focused_client_to_tag("Term")
		end, { description = "Move client to tag 1 (Term)", group = "Tag" }),

		awful.key({ win, "Shift" }, "#11", function()
			move_focused_client_to_tag("Web")
		end, { description = "Move client to tag 2 (Web)", group = "Tag" }),

		awful.key({ win, "Shift" }, "#12", function()
			move_focused_client_to_tag("Mail")
		end, { description = "Move client to tag 3 (Mail)", group = "Tag" }),

		awful.key({ win, "Shift" }, "#13", function()
			move_focused_client_to_tag("Misc")
		end, { description = "Move client to tag 4 (Misc)", group = "Tag" })
	)

	return clientkeys, globalkeys
end

-------------------- Definitions --------------------

terminal = "alacritty"
browser = "firefox"
editor = "nvim"
editor_cmd = terminal .. " -e " .. editor
rofi_cmd = "rofi -dpi " .. dpi(80) .. " -show run"
rofi_emoji_cmd = "rofi -dpi " .. dpi(80) .. " -show emoji -modi emoji"
rofi_calc_cmd = "rofi -dpi " .. dpi(80) .. " -show calc -modi calc"

win = "Mod4"
alt = "Mod1"
ctrl = "Control"

-------------------- Dropdown terminal from lain --------------------

my_dropdown = lain.util.quake({
	app = terminal,
	argname = "--class %s",
	name = "myshittydropdown",
	height = 0.5,
	followtag = true,
	visible = false,
})

-------------------- Create a wibox for each screen and add it --------------------

local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ win }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ win }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewprev(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewnext(t.screen)
	end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 2, function(c)
		c:kill()
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

separator = wibox.widget({
	widget = wibox.widget.separator,
	orientation = "horizontal",
	forced_width = 30,
	color = beautiful.separator,
	shape = gears.shape.powerline,
})

separator_empty = wibox.widget({
	widget = wibox.widget.separator,
	orientation = "horizontal",
	forced_width = 10,
	color = beautiful.bg_normal,
})

separator_reverse = wibox.widget({
	widget = wibox.widget.separator,
	orientation = "horizontal",
	forced_width = 30,
	span_ratio = 0.7,
	color = beautiful.separator,
	set_shape = function(cr, width, height)
		-- gears.shape.parallelogram(cr, width, height)
		gears.shape.powerline(cr, width, height, (height / 2) * -1)
	end,
})

local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local lain = require("lain")
local beautiful = require("beautiful")
local my_utils = require("my_modules/my_utils")
local awful = require("awful")

-------------------- Battery --------------------
-- Detect battery adapter
local adapter_name = "BAT0"
if my_utils.file_exists("/sys/class/power_supply/BAT1/status") then
	adapter_name = "BAT1"
end

-- Icon widget with forced size
local battery_image_widget = wibox.widget({
	image = beautiful.battery_icon_empty,
	resize = true,
	forced_height = dpi(18),
	forced_width = dpi(18),
	widget = wibox.widget.imagebox,
})

-- Tooltip on hover
local bat_tooltip = get_tooltip(battery_image_widget)

-- Text widget
local battery_text_widget = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	valign = "center",
	font = beautiful.font,
})

-- Margin between icon and text
local battery_text_margin = wibox.container.margin(battery_text_widget, dpi(5), 0, 0, 0)

-- Horizontal layout
local battery_inner_widget = wibox.widget({
	battery_image_widget,
	battery_text_margin,
	layout = wibox.layout.fixed.horizontal,
})

-- Outer margin
local battery_widget = wibox.container.margin(battery_inner_widget, dpi(2), dpi(4), dpi(2), dpi(2))

-- Lain battery logic
lain.widget.bat({
	battery = adapter_name,
	full_notify = "off",
	settings = function()
		local perc = ""
		local battery_widget_color = beautiful.fg_normal
		local battery_image = beautiful.battery_icon_full

		if bat_now.status == "Charging" then
			battery_widget_color = beautiful.fg_normal_alt or "#8ec07c"
			battery_image = beautiful.battery_icon_charging
		elseif bat_now.status == "Full" then
			battery_image = beautiful.battery_icon_full
			perc = ""
		else
			battery_widget_color = beautiful.fg_normal_alt or "#a89984"
			if tonumber(bat_now.perc) then
				if bat_now.perc > 80 then
					battery_image = beautiful.battery_icon_full
				elseif bat_now.perc > 40 then
					battery_image = beautiful.battery_icon_medium
				elseif bat_now.perc > 20 then
					battery_image = beautiful.battery_icon_low
				else
					battery_image = beautiful.battery_icon_empty
					battery_widget_color = "#fb4934" -- alert red
				end
			end
		end

		if bat_now.perc ~= "N/A" and tonumber(bat_now.perc) and bat_now.perc <= 90 then
			perc = bat_now.perc .. "%"
		end

		battery_text_widget:set_markup(lain.util.markup.fontfg(beautiful.font, battery_widget_color, perc))
		battery_image_widget:set_image(gears.color.recolor_image(battery_image, battery_widget_color))
		bat_tooltip.text = bat_now.status .. " (" .. perc .. ")"
	end,
})

-- Click to manually update
battery_widget:buttons(awful.util.table.join(awful.button({}, 1, function()
	battery_text_widget:update()
end)))

-------------------- Create a textclock widget and attach the calendar --------------------

mytextclock = wibox.widget({
	widget = wibox.widget.textclock,
	format = " %d %b %H:%M (%a) ",
	refresh = 30,
})

calendarwidget = lain.widget.cal({
	followtag = true,
	week_number = "left",
	attach_to = { mytextclock },
	notification_preset = {
		font = beautiful.font_big,
		fg = beautiful.fg_normal,
		bg = beautiful.bg_focus,
	},
})

-------------------- Change tag names dynamically --------------------

refresh_tag_name = function()
	for s = 1, screen.count() do
		-- get a list of all tags
		local atags = screen[s].tags
		for i, t in ipairs(atags) do
			local clients_on_this_tag = 0
			for i, c in ipairs(t:clients()) do
				if not c.skip_taskbar then
					clients_on_this_tag = clients_on_this_tag + 1
				end
			end
			original_name = my_utils.get_first_word(t.name)
			t.name = original_name .. " " .. string.rep("", clients_on_this_tag)
		end
	end
end

client.connect_signal("unmanage", function(c, startup)
	if c.type == "normal" then
		focus_previous_client(c.screen.selected_tag.name, printmore)
	end
	refresh_tag_name()
end)

-------------------- Some widget stuff --------------------

nextthing_timer = gears.timer({
	timeout = 30,
	autostart = true,
	call_now = true,
	callback = function()
		nextthing:check()
	end,
})

local void_logo = wibox.widget.imagebox()
void_logo.image = gears.surface.load_uncached("/home/aman/.config/awesome/my_modules/assets/void.svg")
void_logo.resize = true
void_logo.forced_height = dpi(20)
void_logo.forced_width = dpi(20)

local function screen_organizer(s, primary, is_extra)
	debug_print("Now organizing screen: " .. s["name"], printmore)

	local void_logo_margin = wibox.container.margin(void_logo, dpi(6), dpi(8), dpi(4), dpi(4))

	s["object"].mylayoutbox = awful.widget.layoutbox(s["object"])
	s["object"].mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))

	-------------------- Some convenience stuff --------------------

	if screen:count() > 1 then
		taglist_width = dpi(250)
		wibar_height = dpi(25)
	else
		taglist_width = dpi(350)
		wibar_height = dpi(23)
	end

	if not is_extra then
		-- Create a taglist widget
		s["object"].mytaglist = awful.widget.taglist({
			screen = s["object"],
			filter = awful.widget.taglist.filter.all,
			style = {
				shape = gears.shape.powerline,
			},
			layout = {
				spacing = -15,
				spacing_widget = {
					color = beautiful.bg_normal,
					shape = gears.shape.powerline,
					widget = wibox.widget.separator,
				},
				layout = wibox.layout.flex.horizontal,
				forced_width = taglist_width,
			},
			widget_template = {
				{
					{
						{
							id = "text_role",
							widget = wibox.widget.textbox,
						},
						layout = wibox.layout.flex.horizontal,
					},
					left = 24,
					right = 12,
					widget = wibox.container.margin,
				},
				id = "background_role",
				widget = wibox.container.background,
			},
			buttons = taglist_buttons,
		})

		s["object"].mytasklist = awful.widget.tasklist({
			screen = s["object"],
			filter = awful.widget.tasklist.filter.currenttags,
			style = {
				shape = gears.shape.powerline,
			},
			layout = {
				spacing = -15,
				spacing_widget = {
					color = beautiful.bg_normal,
					shape = gears.shape.powerline,
					widget = wibox.widget.separator,
				},
				layout = wibox.layout.flex.horizontal,
			},
			widget_template = {
				{
					{
						{
							id = "text_role",
							widget = wibox.widget.textbox,
						},
						layout = wibox.layout.flex.horizontal,
					},
					left = 18,
					right = 18,
					widget = wibox.container.margin,
				},
				id = "background_role",
				widget = wibox.container.background,
			},
			buttons = tasklist_buttons,
		})
	end

	-------------------- Wibar --------------------

	s["object"].mywibox = awful.wibar({
		position = "top",
		screen = s["object"],
		height = wibar_height,
	})

	systray_right_widgets = {
		layout = wibox.layout.fixed.horizontal,
	}

	table.insert(systray_right_widgets, separator_empty)

	if primary then
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, battery_widget)
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, cpu_widget)
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, mem_widget)
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, net_widget)
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, sound_widget)
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, mic_widget)
		table.insert(systray_right_widgets, my_systray)
	end
	table.insert(systray_right_widgets, capslock)
	if primary then
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, mytextclock)
	else
		table.insert(systray_right_widgets, nextthing)
		table.insert(systray_right_widgets, separator_reverse)
		table.insert(systray_right_widgets, separator_empty)
	end
	table.insert(systray_right_widgets, s["object"].mylayoutbox)

	if is_extra then
		s["object"].mywibox:setup({
			layout = wibox.layout.align.horizontal,
			{
				void_logo_margin,
				layout = wibox.layout.align.horizontal,
				separator,
			},
			systray_right_widgets,
		})
	else
		-- Normal setup, tag and taskslists
		s["object"].mywibox:setup({
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				void_logo_margin,
				layout = wibox.layout.align.horizontal,
				s["object"].mytaglist,
				separator,
			},
			s["object"].mytasklist, -- Middle widget
			systray_right_widgets,
		})
	end
end

-------------------- Screen stuff --------------------

function place_tags(properties, primary, screens_table)
	if my_utils.table_length(screens_table) == 1 then
		-- Only 1 screen here, no need for drama
		for _, tag in pairs(root.tags()) do
			table.insert(screens_table[properties["name"]]["tags"], tag)
			if tag.screen ~= properties["object"] then
				tag.screen = properties["object"]
			end
		end
	else
		for _, tag in pairs(root.tags()) do
			local first_word = my_utils.get_first_word(tag.name)
			if primary == false and (first_word == "Web" or first_word == "Mail") then
				if tag.screen ~= properties["object"] then
					debug_print("Re-assigning " .. first_word, printmore)
					tag.screen = properties["object"]
					table.insert(screens_table[properties["name"]]["tags"], tag)
				else
					debug_print(first_word .. " is already on correct screen", printmore)
					table.insert(screens_table[properties["name"]]["tags"], tag)
				end
			elseif primary == true and (first_word == "Term" or first_word == "Misc") then
				if tag.screen ~= properties["object"] then
					debug_print("Re-assigning " .. first_word, printmore)
					tag.screen = properties["object"]
					table.insert(screens_table[properties["name"]]["tags"], tag)
				else
					debug_print(first_word .. " is already on correct screen", printmore)
					table.insert(screens_table[properties["name"]]["tags"], tag)
				end
			end
		end
	end

	-- ordering shit
	for _, tag in pairs(root.tags()) do
		if tag.name == "Term" then
			tag.index = 1
		elseif tag.name == "Mail" then
			tag.index = 3
		elseif tag.name == "Web" then
			tag.index = 2
		else
			tag.index = 4
		end
	end
end

function process_screens(systray, screens_table, printmore)
	systray = systray or nil

	debug_print("Processing screens result: " .. my_utils.dump(screens_table), printmore)

	second_screen_already_processed = false
	for name, properties in pairs(screens_table) do
		-- In case we have more than 2 screens, we will register first
		-- non-primary screen as 2nd, others won't get tags.
		if properties["primary"] then
			-- this is the "primary" screen so it should have the systray
			systray:set_screen(properties["object"])
			screen_organizer(properties, true, false, false)
			debug_print("Checking tags for: " .. name .. " (primary) ", printmore)
			place_tags(properties, true, screens_table)
		else
			screen_organizer(properties, false, second_screen_already_processed)
			if second_screen_already_processed then
				debug_print("Extra screen found: " .. my_utils.dump(properties["object"]), printmore)
			else
				debug_print("Checking tags for: " .. name .. " (not primary) ", printmore)
				place_tags(properties, false, screens_table)
				second_screen_already_processed = true
			end
		end
	end
	-- define rules since we have filled the screen table
	dofile("/home/aman/.config/awesome/my_modules/rc_rules.lua")

	clientkeys, globalkeys = set_keys_after_screen_new(clientkeys, globalkeys, printmore)
	dofile("/home/aman/.config/awesome/my_modules/rc_clientbuttons.lua")
	root.keys(globalkeys)
	set_rules(clientkeys)
end

-------------------- Mouse bindings --------------------
root.buttons(gears.table.join(awful.button({}, 4, awful.tag.viewprev), awful.button({}, 5, awful.tag.viewnext)))

-------------------- Key bindings --------------------

globalkeys = gears.table.join(
	globalkeys,

	-- AwesomeWM

	awful.key({ win, "Shift" }, "h", function()
		hotkeys_popup.show_help(nil, awful.screen.focused())
	end, { description = "Show keybindings help", group = "Awesome" }),

	awful.key({ win, ctrl }, "q", awesome.quit, { description = "Quit AwesomeWM", group = "Awesome" }),

	awful.key({ win, ctrl }, "r", function()
		save_current_tags(screens_table)
		awesome.restart()
	end, { description = "Restart AwesomeWM", group = "Awesome" }),

	-- Brightness

	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn.with_shell("bash /home/aman/.config/awesome/brightness_control.sh up")
	end, { description = "Increase brightness", group = "Brightness" }),

	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn.with_shell("bash /home/aman/.config/awesome/brightness_control.sh down")
	end, { description = "Decrease brightness", group = "Brightness" }),

	-- Audio

	awful.key({}, "0x1008ff13", function()
		awful.spawn("amixer sset Master 5%+", false)
		awesome.emit_signal("volume::change")
	end, { description = "Volume up", group = "Audio" }),

	awful.key({}, "0x1008ff11", function()
		awful.spawn("amixer sset Master 5%-", false)
		awesome.emit_signal("volume::change")
	end, { description = "Volume down", group = "Audio" }),

	awful.key({}, "0x1008ffb2", function()
		awful.spawn("amixer sset Capture toggle", false)
		awesome.emit_signal("mic")
	end, { description = "Toggle mic mute", group = "Audio" }),

	-- Media

	awful.key({}, "XF86AudioNext", function()
		awful.spawn("mpc next", false)
	end, { description = "Next track", group = "Media" }),

	awful.key({}, "XF86AudioPrev", function()
		awful.spawn("mpc prev", false)
	end, { description = "Previous track", group = "Media" }),

	awful.key({}, "XF86AudioPlay", function()
		awful.spawn("mpc toggle", false)
	end, { description = "Play/Pause music", group = "Media" }),

	-- Focus navigation via knob

	awful.key({ win }, "XF86AudioRaiseVolume", function()
		root.fake_input("key_press", 196)
		root.fake_input("key_release", 196)
	end, { description = "Cycle windows forward", group = "Focus" }),

	awful.key({ win }, "XF86AudioLowerVolume", function()
		root.fake_input("key_press", "Shift_L")
		root.fake_input("key_press", 196)
		root.fake_input("key_release", 196)
		root.fake_input("key_release", "Shift_L")
	end, { description = "Cycle windows backward", group = "Focus" }),

	-- Screenshot

	awful.key({}, "Print", function()
		awful.spawn("flameshot gui")
	end, { description = "Screenshot with GUI", group = "Screenshot" }),

	awful.key({ "Shift" }, "Print", function()
		awful.spawn("flameshot full -c")
	end, { description = "Fullscreen screenshot to clipboard", group = "Screenshot" }),

	-- Dropdown terminal

	awful.key({}, "F12", function()
		my_dropdown:toggle()
	end, { description = "Toggle dropdown terminal", group = "Terminal" }),

	-- Rofi

	awful.key({ win }, "p", function()
		awful.spawn(rofi_cmd)
	end, { description = "Application launcher (rofi)", group = "Rofi" }),

	awful.key({}, "F9", function()
		awful.spawn(rofi_emoji_cmd)
	end, { description = "Emoji picker", group = "Rofi" }),

	awful.key({ ctrl }, "F9", function()
		awful.spawn(rofi_calc_cmd)
	end, { description = "Calculator", group = "Rofi" }),

	awful.key({ "Shift" }, "F9", function()
		awful.spawn(rofi_subsuper)
	end, { description = "Subscript/superscript", group = "Rofi" }),

	awful.key({ ctrl, alt }, "c", function()
		awful.spawn(greenclip_cmd)
	end, { description = "Clipboard manager", group = "Rofi" }),

	-- Apps

	awful.key({ win }, "b", function()
		awful.spawn(browser)
	end, { description = "Open browser", group = "Apps" }),

	awful.key({ win }, "c", function()
		awful.spawn("chromium")
	end, { description = "Open Chromium", group = "Apps" }),

	awful.key({ win }, "f", function()
		awful.spawn("thunar")
	end, { description = "Open Thunar", group = "Apps" }),

	awful.key({ win }, "m", function()
		awful.spawn("thunderbird")
	end, { description = "Open Thunderbird", group = "Apps" }),

	awful.key({ win, "Shift" }, "Return", function()
		awful.spawn(terminal)
	end, { description = "Launch terminal", group = "Apps" }),

	awful.key({ win, "Shift" }, "n", function()
		awful.spawn("alacritty -e nvim /home/aman/.nextthing")
	end, { description = "Edit .nextthing", group = "Apps" }),

	-- Power

	awful.key({ win }, "l", function()
		awful.spawn("slock")
	end, { description = "Lock screen", group = "Power" }),

	awful.key({ win }, "XF86WakeUp", function()
		awful.spawn("sudo systemctl suspend")
	end, { description = "Suspend system", group = "Power" }),

	-- Layout / Tags

	awful.key({ win }, "space", function()
		awful.layout.inc(1)
	end, { description = "Next layout", group = "Layout" }),

	awful.key({ win }, "Tab", function()
		awful.client.focus.byidx(1)
	end, { description = "Focus next client", group = "Focus" }),

	awful.key({ win, "Shift" }, "Tab", function()
		awful.client.focus.byidx(-1)
	end, { description = "Focus previous client", group = "Focus" }),

	awful.key({ win }, "Caps_Lock", function()
		awful.tag.viewnext(get_screen_of_focused())
	end, { description = "Next tag", group = "Tag" }),

	awful.key({ win, "Shift" }, "Tab", function()
		awful.tag.viewprev(get_screen_of_focused())
	end, { description = "Previous tag", group = "Tag" }),

	-- Misc

	awful.key({ ctrl, alt }, "p", function()
		notifytest()
	end, { description = "Notify test", group = "Misc" })
)

-- needed for capslock helper
gears.table.merge(globalkeys, capslock.possible_combinations)

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	refresh_tag_name()
	if not awesome.startup then
		awful.client.setslave(c)
	end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

client.connect_signal("property::minimized", function(c)
	-- If a sticky window is minimized, ensure it's visible on taskbar
	if c.sticky then
		c.skip_taskbar = false
	end
	if c.type == "normal" then
		focus_previous_client(c.screen.selected_tag.name, printmore)
	end
end)

client.connect_signal("focus", function(c)
	-- If a sticky window is unminimized, remove from taskbar
	if c.sticky and not c.minimized then
		c.skip_taskbar = true
	end
	c.border_color = beautiful.border_focus
end)

-- Screen handling
screen.connect_signal("list", function()
	debug_print("List signal received", printmore)
	if my_utils.file_age("/home/aman/.awesome_screen_setup_lock", printmore) < 4 then
		debug_print("There is already another lock waiting, skipping this screen change", printmore)
	else
		os.execute("touch /home/aman/.awesome_screen_setup_lock")
		debug_print("Sleeping for 2 secs", printmore)
		os.execute("sleep 2")
		screens_table = get_screens()
		process_screens(my_systray, screens_table, printmore)
	end
end)

os.execute("touch /home/aman/.awesome_screen_setup_lock")
screens_table = get_screens()
process_screens(my_systray, screens_table, printmore)

tag.connect_signal("request::screen", function(t)
	-- recover tags on a removed screen
	naughty.notify({ text = "Recovering tag: " .. t.name })
	for s in screen do
		t.screen = s
		my_dropdown.screen = s
		my_dropdown.visible = false
		return
	end
end)

tag.connect_signal("request::default_layouts", function()
	awful.layout.layouts = {
		awful.layout.suit.tile,
		awful.layout.suit.max,
	}
end)

client.connect_signal("mouse::enter", function(c)
	if c.ontop and c.sticky and c.skip_taskbar and c.marked then
		c.opacity = 0.9
		-- Run away from mouse, to the other side of the screen
		if c.x > (c.screen.geometry.x + c.screen.geometry.width - 600) then
			c:relative_move(-(c.screen.geometry.width - c.width), 0, 0, 0)
		else
			c:relative_move((c.screen.geometry.width - c.width), 0, 0, 0)
		end
	end
end)

client.connect_signal("mouse::enter", function(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
		client.focus = c
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

awesome.connect_signal("save-tags", function()
	-- We are about to exit / restart awesome, save our last used tag
	save_current_tags(screens_table)
end)

tag.connect_signal("property::layout", function(t)
	-- make the focused window master on layout change
	local c = client.focus
	if c and awful.layout.get(t.screen).name == "max" then
		awful.client.setmaster(c)
		c:raise()
	end
end)

client.connect_signal("property::size", function(c)
	-- workaround for exiting fullscreen on floating windows
	-- some params do not stay as they should, so we enforce them
	if c.floating and c.skip_taskbar and not c.fullscreen then
		c.sticky = true
		c.ontop = true
	end
end)

client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal

	-- auto-hide dropdown
	if c.instance == my_dropdown.name then
		my_dropdown.visible = not my_dropdown.visible
		my_dropdown:display()
	end
end)

client.connect_signal("property::urgent", function(c)
	if c.urgent then
		c.urgent_since = os.time()
	end
end)

-- When switching to a tag with urgent clients, raise them.
awful.tag.attached_connect_signal(s, "property::selected", function()
	local urgent_clients = function(c)
		return awful.rules.match(c, { urgent = true })
	end
	for c in awful.client.iterate(urgent_clients) do
		if c.first_tag == mouse.screen.selected_tag then
			client.focus = c
			c:raise()
		end
	end
end)

awesome.connect_signal("startup", function(s, state)
	awful.spawn.with_shell("start-pipewire")
	run_once("picom")

	-- standard alt+tab
	run_once(
		'alttab -w 1 -t 400x300 -frame "' .. string.upper(beautiful.fg_normal) .. '" -i 100x100 -font xft:firacode-20',
		"400x300"
	)
	-- Alt+Tab for switching all windows
	run_once(
		'alttab -w 1 -t 250x100 -frame "'
			.. string.upper(beautiful.fg_normal)
			.. '" -d 1 -kk 0x1008ff49 -mk Super_L -i 50x50 -font xft:firacode-10 -vertical -p none',
		"0x1008ff49"
	)
end)

for s in screen do
	set_wallpaper(s)
end

debug_print("Last state of the screens table is: \n" .. my_utils.dump(screens_table), printmore)
load_last_active_tags(screens_table, printmore)
