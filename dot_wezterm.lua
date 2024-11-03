-- Press Control+Shift+L to see logs. Use wezterm.log_info() for outputs.

-- imports
local wezterm = require("wezterm")
local gui = wezterm.gui

-- utility functions
local function is_dark()
	-- wezterm.gui is not always available, depending on what
	-- environment wezterm is operating in. Just return true
	-- if it's not defined.
	if gui then
		-- Some systems report appearance like "Dark High Contrast"
		-- so let's just look for the string "Dark" and if we find
		-- it assume appearance is dark.
		return gui.get_appearance():find("Dark")
	end
	return true
end

local function merge_tables(defaults, overrides)
	for k, v in pairs(overrides) do
		defaults[k] = v
	end
	return defaults
end

-- globals
local action = wezterm.action
local config = wezterm.config_builder()

-- reusable key shortcuts
local tmux_window_new = action.Multiple({
	action.SendKey({ key = "a", mods = "CTRL" }),
	action.SendKey({ key = "c" }),
})
local tmux_window_next = action.Multiple({
	action.SendKey({ key = "a", mods = "CTRL" }),
	action.SendKey({ key = "n" }),
})
local tmux_window_prev = action.Multiple({
	action.SendKey({ key = "a", mods = "CTRL" }),
	action.SendKey({ key = "p" }),
})
local tmux_window_kill = action.Multiple({
	action.SendKey({ key = "a", mods = "CTRL" }),
	action.SendKey({ key = "&" }),
})
local tmux_pane_new_up = action.Multiple({
	action.SendKey({ key = "a", mods = "CTRL" }),
	action.SendKey({ key = "-" }),
	action.SendKey({ key = "a", mods = "CTRL" }),
	action.SendKey({ key = "{" }),
})
local tmux_pane_new_down = action.Multiple({
	action.SendKey({ key = "a", mods = "CTRL" }),
	action.SendKey({ key = "-" }),
})
local tmux_pane_new_right = action.Multiple({
	action.SendKey({ key = "a", mods = "CTRL" }),
	action.SendKey({ key = "|" }),
})
local tmux_pane_new_left = action.Multiple({
	action.SendKey({ key = "a", mods = "CTRL" }),
	action.SendKey({ key = "|" }),
	action.SendKey({ key = "a", mods = "CTRL" }),
	action.SendKey({ key = "{" }),
})
local tmux_pane_kill = action.Multiple({
	action.SendKey({ key = "a", mods = "CTRL" }),
	action.SendKey({ key = "x" }),
})

-- config defaults
local default_dark_theme = "nord"
local default_light_theme = "Ef-Deuteranopia-Light"
-- Other choices: 'Alabaster', '3024 Day', 'Ashes (light) (terminal.sexy)', 'AtomOneLight', 'ayu_light', 'Bluloco Light (Gogh)', 'Bluloco Zsh Light (Gogh)', 'Catppuccin Latte', 'Classic Light (base16)', 'Ef-Deuteranopia-Light'
local defaults = {
	window_close_confirmation = "NeverPrompt",
	window_background_opacity = 0.95,
	color_scheme = is_dark() and default_dark_theme or default_light_theme,
	font = wezterm.font("DejaVu Sans Mono"),
	font_size = 9,
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
	window_decorations = "TITLE | RESIZE",
	window_frame = {
		font = wezterm.font({ family = "DejaVu Sans", weight = "Bold" }),
		font_size = 12,
	},
	hide_mouse_cursor_when_typing = false,
	hide_tab_bar_if_only_one_tab = true,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	initial_cols = math.floor(80 * 1.5),
	initial_rows = math.floor(24 * 1.5),

	keys = {
		-- tmux
		{ key = "t", mods = "CTRL|SHIFT", action = tmux_window_new },
		{ key = "n", mods = "CTRL|SHIFT", action = tmux_window_next },
		{ key = "p", mods = "CTRL|SHIFT", action = tmux_window_prev },
		{ key = "w", mods = "CTRL|SHIFT", action = tmux_window_kill },
		{ key = "UpArrow", mods = "CTRL|SHIFT", action = tmux_pane_new_up },
		{ key = "DownArrow", mods = "CTRL|SHIFT", action = tmux_pane_new_down },
		{ key = "LeftArrow", mods = "CTRL|SHIFT", action = tmux_pane_new_left },
		{ key = "RightArrow", mods = "CTRL|SHIFT", action = tmux_pane_new_right },

		{ key = "w", mods = "CTRL|SHIFT|ALT", action = tmux_pane_kill },
		-- wezterm
		{ key = "n", mods = "CTRL|ALT", action = action.SpawnWindow },
	},
}

-- platform overrides
local platform = {
	["x86_64-pc-windows-msvc"] = {},
	["x86_64-apple-darwin"] = {},
	["aarch64-apple-darwin"] = {
		font = wezterm.font("DejaVu Sans Mono for Powerline"),
		font_size = 12.0,
		macos_window_background_blur = 10,
	},
	["x86_64-unknown-linux-gnu"] = {
		enable_wayland = false,
		window_background_opacity = 0.97,
	},
}

-- hostname overrides
local hostname = {
	surface = {
		font_size = 7.5,
		hide_tab_bar_if_only_one_tab = false,
		window_decorations = "INTEGRATED_BUTTONS|RESIZE",
	},
}

-- display overrides
local display = {
	["Built-in Retina Display"] = {
		-- macOS "more space"
		["3600x2338"] = {
			font_size = 13,
		},
		-- macOS "default"
		["3024x1964"] = {
			font_size = 11,
		},
	},
}

-- merging default and overrides
local merged = merge_tables(defaults, platform[wezterm.target_triple])
merged = merge_tables(merged, hostname[wezterm.hostname()] or {})
config = merge_tables(config, merged)

-- event handlers
wezterm.on("window-config-reloaded", function(window, _)
	-- Information about the current screens can be accessed only
	-- inside event threads.
	local current_overrides = window:get_config_overrides() or {}
	local active_display = wezterm.gui.screens()["active"]
	local overrides = display[active_display["name"]] or {}
	local resolution = active_display["width"] .. "x" .. active_display["height"]

	overrides = overrides[resolution] or {}
	for k, v in pairs(overrides) do
		if not current_overrides[k] then
			current_overrides[k] = v
		else
			local cur_val = current_overrides[k]
			if cur_val ~= v then
				current_overrides[k] = v
			end
		end
		window:set_config_overrides(current_overrides)
	end
end)

return config
