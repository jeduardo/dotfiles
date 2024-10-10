-- Press Control+Shift+L to see logs. Use wezterm.log_info() for outputs.

-- imports
local wezterm = require('wezterm')

-- globals
local action = wezterm.action
local config = wezterm.config_builder()
local hostname = wezterm.hostname()

-- utility functions
function is_dark()
  -- wezterm.gui is not always available, depending on what
  -- environment wezterm is operating in. Just return true
  -- if it's not defined.
  if wezterm.gui then
    -- Some systems report appearance like "Dark High Contrast"
    -- so let's just look for the string "Dark" and if we find
    -- it assume appearance is dark.
    return wezterm.gui.get_appearance():find("Dark")
  end
  return true
end

function get_color_scheme()
  if is_dark() then
    return 'nord'
  end
  return 'Ashes (light) (terminal.sexy)'
end

function merge_tables(defaults, overrides)
  for k,v in pairs(overrides) do defaults[k] = v end
  return defaults
end

-- config defaults
local defaults = {
  window_close_confirmation = 'NeverPrompt',
  window_background_opacity = 0.95,
  color_scheme = get_color_scheme(),
  font = wezterm.font('Source Code Pro'),
  font_size = 7.5,
  window_decorations = 'RESIZE',
  window_frame = {
    font = wezterm.font({ family = 'DejaVu Sans', weight = 'Bold' }),
    font_size = 9,
  },
  hide_mouse_cursor_when_typing = false,
  hide_tab_bar_if_only_one_tab = true,
  keys = {
    { key = 'T', mods = 'CTRL', action = action.SpawnTab 'CurrentPaneDomain' },
    { key = 'T', mods = 'SHIFT|CTRL', action = action.SpawnTab 'CurrentPaneDomain' },
    { key = 't', mods = 'SHIFT|CTRL', action = action.SpawnTab 'CurrentPaneDomain' },
    { key = 't', mods = 'SUPER', action = action.SpawnTab 'CurrentPaneDomain' },
  },
}

-- platform overrides
local platform = {
  ["x86_64-pc-windows-msvc"] = {},
  ["x86_64-apple-darwin"] = {},
  ["aarch64-apple-darwin"] = {
    font = wezterm.font('DejaVu Sans Mono for Powerline'),
    font_size = 12.0
  },
  ["x86_64-unknown-linux-gnu"] = {
    window_background_opacity = 0.97,
  },
}

-- hostname overrides
local hostname = {
  surface = {
    font_size = 10
  }
}

wezterm.log_info(wezterm.hostname)

-- merging config
local merged = merge_tables(defaults, platform[wezterm.target_triple])
merged = merge_tables(merged, hostname[wezterm.hostname()] or {})
config = merge_tables(config, merged)

return config
