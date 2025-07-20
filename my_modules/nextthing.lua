local awful = require("awful")
local wibox = require("wibox")
local my_utils = require("my_modules/my_utils")
local my_theme = require("my_modules/my_theme")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")

local spacer_string = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	valign = "center",
	font = my_theme.font,
})
spacer_string:set_markup_silently(" ")

local nextthingtext = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	valign = "center",
	font = my_theme.font,
})

local left_image_base = wibox.widget({
	resize = true,
	widget = wibox.widget.imagebox,
})
local right_image_base = wibox.widget({
	resize = true,
	widget = wibox.widget.imagebox,
})
left_image_base:set_image(gears.color.recolor_image(my_theme.thing_icon_left, my_theme.fg_normal))
right_image_base:set_image(gears.color.recolor_image(my_theme.thing_icon_right, my_theme.fg_normal))

-- bottom margin to match visually
local left_image = wibox.container.margin(left_image_base, nil, nil, nil, dpi(2))
local right_image = wibox.container.margin(right_image_base, nil, nil, nil, dpi(2))

local nextthingwidget = wibox.widget({
	left_image,
	spacer_string,
	nextthingtext,
	spacer_string,
	right_image,
	layout = wibox.layout.fixed.horizontal,
})

-- set text of nextthing widget

function nextthingwidget:set(thing, exists)
	if exists then
		left_image_base:set_image(gears.color.recolor_image(my_theme.thing_icon_left, my_theme.fg_normal))
		right_image_base:set_image(gears.color.recolor_image(my_theme.thing_icon_right, my_theme.fg_normal))
	end

	if awful.util.escape(thing) == "No tasks" then
		nextthingtext:set_markup_silently("<span foreground='#888888'>" .. awful.util.escape(thing) .. "</span>")
	else
		nextthingtext:set_markup_silently(awful.util.escape(thing))
	end
end

function nextthingwidget:check()
	awful.spawn.easy_async(
		"bash -c \"head -1 ~/.nextthing 2>/dev/null || echo ''\"",
		function(stdout, stderr, reason, exit_code)
			local text = stdout:match("^%s*$") and "No tasks" or stdout:sub(1, 40)
			nextthingwidget:set(text, true)
		end
	)
end

nextthingwidget:check()

return nextthingwidget
