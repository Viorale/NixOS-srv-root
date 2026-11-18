-- Completion with blink.cmp — the template's completion engine — wearing
-- NeonPane's completion look (glass when transparency is on, a neutral frost
-- otherwise, kind icons colored by family).
--
-- One plugin covers what NeonPane needed five for (nvim-cmp + cmp-buffer +
-- cmp-path + cmp-cmdline + cmp-nvim-lsp): LSP, path, buffer, snippets, the
-- `:` and `/` command line, and signature help.
--
-- `version = "1.*"` makes lazy.nvim install a tagged release, which ships a
-- prebuilt Rust fuzzy matcher. `prefer_rust_with_warning` falls back to the Lua
-- matcher (and says so once) if that binary can't load — the safe choice on
-- NixOS, where downloaded binaries occasionally miss a library.

local BORDER = "rounded"

--- Completion highlights, derived from the active theme on every switch.
local function apply_highlights()
  local ui = require("core.ui")
  local p = ui.palette()
  local hl = vim.api.nvim_set_hl

  -- Nothing at all while the editor is transparent, so the terminal's own
  -- blur shows through the menu; a neutral frost otherwise.
  local menu_bg = ui.pane_bg(0.1)
  local menu_fg = ui.contrast(ui.frost(0.1), p.bg, p.fg)

  -- A transparent pane needs a visible rim of its own; an opaque one reads
  -- borderless when the rim is painted in the pane's color.
  local rim = vim.g.ui_transparent and ui.blend(p.accent, p.bg, 0.45) or menu_bg

  hl(0, "BlinkCmpMenu", { bg = menu_bg, fg = menu_fg })
  hl(0, "BlinkCmpMenuBorder", { bg = menu_bg, fg = rim })
  hl(0, "BlinkCmpMenuSelection", { bg = p.selection_bg, fg = p.selection_fg, bold = true })
  hl(0, "BlinkCmpScrollBarThumb", { bg = p.accent })
  hl(0, "BlinkCmpScrollBarGutter", { bg = ui.pane_bg(0.14) })

  hl(0, "BlinkCmpDoc", { bg = menu_bg, fg = menu_fg })
  hl(0, "BlinkCmpDocBorder", { bg = menu_bg, fg = rim })
  hl(0, "BlinkCmpDocSeparator", { bg = menu_bg, fg = rim })
  hl(0, "BlinkCmpSignatureHelp", { bg = menu_bg, fg = menu_fg })
  hl(0, "BlinkCmpSignatureHelpBorder", { bg = menu_bg, fg = rim })
  hl(0, "BlinkCmpSignatureHelpActiveParameter", { fg = p.accent, bold = true, underline = true })

  hl(0, "BlinkCmpLabel", { fg = menu_fg })
  hl(0, "BlinkCmpLabelMatch", { fg = p.accent, bold = true })
  hl(0, "BlinkCmpLabelDeprecated", { fg = p.muted, strikethrough = true })
  hl(0, "BlinkCmpLabelDetail", { fg = p.muted })
  hl(0, "BlinkCmpLabelDescription", { fg = p.muted, italic = true })
  hl(0, "BlinkCmpSource", { fg = p.muted, italic = true })
  hl(0, "BlinkCmpGhostText", { fg = p.muted, italic = true })

  -- Kinds grouped by what they are. A list of pairs rather than a table keyed
  -- by color: palette entries fall back to one another (pink → purple, ...),
  -- and two equal hex keys would silently drop a whole row of kinds.
  local kind_groups = {
    { p.pink, { "Function", "Method", "Constructor", "Event" } },
    { p.cyan, { "Variable", "Property", "Field", "Reference" } },
    { p.purple, { "Class", "Interface", "Struct", "Enum", "EnumMember", "Module", "TypeParameter" } },
    { p.yellow, { "Keyword", "Operator", "Unit", "Value" } },
    { p.orange, { "Constant", "Color" } },
    { p.green, { "Snippet", "Text" } },
    { p.blue, { "File", "Folder" } },
  }

  hl(0, "BlinkCmpKind", { fg = p.cyan })
  for _, group in ipairs(kind_groups) do
    local color, kinds = group[1], group[2]
    for _, kind in ipairs(kinds) do
      hl(0, "BlinkCmpKind" .. kind, { fg = color })
    end
  end
end

return {
  "saghen/blink.cmp",
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    -- VS Code style snippet library, read by blink's built-in snippet source.
    "rafamadriz/friendly-snippets",
  },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      -- "default": <C-space> open, <C-y> accept, <C-n>/<C-p> move, <C-e> close.
      preset = "default",
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
    },

    appearance = { nerd_font_variant = "mono" },

    completion = {
      accept = { auto_brackets = { enabled = true } },
      list = { selection = { preselect = true, auto_insert = false } },
      menu = {
        border = BORDER,
        winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
        draw = {
          -- Layout: [icon]  word ............ Kind (muted), like NeonPane's.
          columns = {
            { "kind_icon" },
            { "label", "label_description", gap = 1 },
            { "kind" },
          },
          components = {
            kind = { highlight = "BlinkCmpSource" },
          },
          treesitter = { "lsp" },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = {
          border = BORDER,
          max_width = 80,
          max_height = 15,
          winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
        },
      },
      ghost_text = { enabled = false },
    },

    signature = {
      enabled = true,
      window = {
        border = BORDER,
        winhighlight = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder",
      },
    },

    sources = {
      default = { "lazydev", "lsp", "path", "snippets", "buffer" },
      providers = {
        -- Neovim's Lua API while editing this config (lua/plugins/lazydev.lua).
        lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        buffer = { min_keyword_length = 3 },
      },
    },

    -- `:` and `/` completion (the template's cmdline.lua, built in here).
    cmdline = {
      enabled = true,
      keymap = { preset = "cmdline" },
      completion = { menu = { auto_show = true } },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },

  config = function(_, opts)
    require("blink.cmp").setup(opts)

    local ui = require("core.ui")
    apply_highlights()
    ui.on_theme_change(ui.create_augroup("NeonBlinkHighlights"), apply_highlights)
  end,
}
