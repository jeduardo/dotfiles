local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})

  --window:gui_window():maximize()
end)

return {
  window_close_confirmation = 'NeverPrompt',
  font = wezterm.font_with_fallback(
    {
--      'DejaVu Sans Mono', {
      'Source Code Pro', {
        family = 'Powerline Symbols',
        weight = 'Regular',
        stretch = 'Normal',
        style = 'Normal',
      },
    }),
  font_size = 10.0,
  --cell_width = 1.0,
  --line_height = 1.0
  --freetype_render_target = 'Light',
  
  hide_tab_bar_if_only_one_tab = true,
  hide_mouse_cursor_when_typing = false,

  window_background_opacity = 0.90,
  --disable_default_key_bindings = true,
  keys = {
    { key = 'T', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'T', mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 't', mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 't', mods = 'SUPER', action = act.SpawnTab 'CurrentPaneDomain' },
  },
  --color_scheme = 'Tangoesque (terminal.sexy)',
  --color_scheme = 'Solarized Dark (base16)',
  color_scheme = 'Dracula',
  --color_scheme = 'WildCherry',
  --color_scheme = 'Terminix Dark (Gogh)',
  --color_scheme = 'theme2 (terminal.sexy)',
  --color_scheme = 'Solarized Dark - Patched',
  --color_scheme = 'Solarized Dark Higher Contrast',
  --color_scheme = 'Synth Midnight Terminal Dark (base16)',
  --color_scheme = 'Papercolor Dark (Gogh)',
  colors = {
    cursor_bg = '#c0c0c0',
    foreground = '#c0c0c0',
    ansi = {
      '#2e3436', --black
      '#cc0000', -- red
      '#4e9a06', -- green
      '#c4a000', -- yellow
      '#3465a4', -- blue
      '#75507b', -- magenta
      '#06989a', -- cyan
      '#d3d7cf', -- white
    },
    brights = {
      '#555753', -- black
      '#ef2929', -- red
      '#8ae234', -- green
      '#fce94f', -- yellow
      '#729fcf', -- blue
      '#ad7fa8', -- magenta
      '#34e2e2', -- cyan
      '#eeeeec', -- white
    },
  },
}
