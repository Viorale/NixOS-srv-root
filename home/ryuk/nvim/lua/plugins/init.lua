-- Aggregated lazy.nvim plugin specs.
--
-- One module per plugin; each returns a spec table or a list of them. Adding a
-- plugin means adding a file under lua/plugins/ and one line here — lazy.nvim
-- receives the flattened list from init.lua.
--
-- Where things come from:
--   (T) feature from greggh/neovim-config-template
--   (N) look / chrome from W-gerber/NeonPane.nvim
--   (+) added for this setup (yazi, fzf-lua, NixOS)

local modules = {
  -- Theme engine + icons (N)
  "base46",
  "web_devicons",

  -- Syntax / editing
  "treesitter", -- (T)
  "treesitter_context", -- (N)
  "rainbow_delimiters", -- (N)
  "snacks", -- (N) animated indent guides + scope line
  "autopairs", -- (T)
  "flash", -- (T)
  "mini", -- (T) mini.icons + mini.surround (returns a list)
  "ccc", -- (T) color picker + inline color highlighting

  -- Language tooling. Servers/formatters/linters come from Nix, not Mason (+)
  "lspconfig", -- (T)
  "lazydev",
  "conform",
  "lint",
  "blink", -- (T) blink.cmp: completion, cmdline, signature help
  "trouble", -- (T)
  "todo_comments", -- (T)

  -- UI / chrome (N)
  "lualine", -- (T) via lua/statusline.lua
  "noice", -- (T)
  "notify",
  "smear_cursor",
  "which_key", -- (T)
  "vimade", -- dim inactive windows
  "scrolleof", -- keep 'scrolloff' honoured at end of buffer

  -- Navigation
  "neo_tree", -- side tree, as in the NeonPane screenshots
  "yazi", -- (+) file manager, replaces the template's Snacks explorer
  "fzf_lua", -- (+) fuzzy finder, replaces the template's Telescope
  "window_picker",
  "smart_splits", -- (T) window moves/resizes, tmux-aware

  -- Terminals / git
  "toggleterm", -- (T)
  "grug_far", -- project search & replace
  "diffview",
  "render_markdown",
  "gitsigns",
  "lazygit", -- (T)
}

local specs = {}

for _, name in ipairs(modules) do
  local spec = require("plugins." .. name)

  -- A module may return either a single spec or a list of them. A single spec
  -- is identifiable by its `[1]` repo string; anything else is a list.
  if type(spec[1]) == "string" then
    specs[#specs + 1] = spec
  else
    vim.list_extend(specs, spec)
  end
end

return specs
