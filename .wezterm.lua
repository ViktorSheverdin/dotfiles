-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

local window_titles = {}

wezterm.on("format-window-title", function(tab, pane, tabs)
	local title = window_titles[tab.window_id]
	if title then
		return title
	end

	local zoom = pane.is_zoomed and "[Z] " or ""
	local index = #tabs > 1 and string.format("[%d/%d] ", tab.tab_index + 1, #tabs) or ""
	return zoom .. index .. pane.title
end)

config.keys = {
	{
		key = "F2",
		mods = "CTRL|SHIFT",
		action = wezterm.action.PromptInputLine {
			description = "Name this window (leave blank to reset)",
			action = wezterm.action_callback(function(window, _, title)
				if title ~= nil then
					window_titles[window:mux_window():window_id()] = title ~= "" and title or nil
				end
			end),
		},
	},
}

-- This is where you actually apply your config choices

config.colors = {
	foreground = "#CBE0F0",
	background = "#011423",
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

config.font = wezterm.font("MesloLGS Nerd Font")
config.font_size = 11

config.cursor_blink_rate = 0
config.enable_tab_bar = false

config.window_decorations = "NONE"
-- config.adjust_window_size_when_changing_font_size = false
config.window_padding = {
	bottom = 0,
}
config.window_background_opacity = 0.9
config.macos_window_background_blur = 10

-- and finally, return the configuration to wezterm
return config
