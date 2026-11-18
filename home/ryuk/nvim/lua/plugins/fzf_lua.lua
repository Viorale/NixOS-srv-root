-- fzf-lua: the fuzzy finder. Replaces the template's Telescope.
--
-- Why fzf-lua: it drives the real `fzf` binary you already use in the shell
-- (same matching, same keys), it is fast on big trees, and it covers every
-- Telescope picker this config used — plus code actions with a diff preview,
-- which stands in for the template's actions-preview.nvim.
--
-- Look: NeonPane's picker style. Prompt and results share one panel, the
-- preview is a box of its own, the title is a solid accent chip, and every
-- surface follows the glass setting (see core/ui.lua `pane_bg`).

--- Theme-derived highlights. fzf-lua reads them each time a picker opens, so a
--- theme switch is picked up by the next picker without restarting anything.
local function apply_highlights()
  local ui = require("core.ui")
  local p = ui.palette()
  local hl = vim.api.nvim_set_hl

  local pane = ui.pane_bg(0.1)
  local rim = vim.g.ui_transparent and ui.blend(p.accent, p.bg, 0.45) or ui.blend(p.accent, p.bg, 0.35)
  local row = ui.frost(0.12)

  hl(0, "FzfLuaNormal", { fg = p.fg, bg = pane })
  hl(0, "FzfLuaBorder", { fg = rim, bg = pane })
  hl(0, "FzfLuaTitle", { fg = ui.contrast(p.accent), bg = p.accent, bold = true })
  hl(0, "FzfLuaBackdrop", { bg = "NONE" })

  hl(0, "FzfLuaPreviewNormal", { fg = p.fg, bg = pane })
  hl(0, "FzfLuaPreviewBorder", { fg = rim, bg = pane })
  hl(0, "FzfLuaPreviewTitle", { fg = p.accent, bg = pane, bold = true })
  hl(0, "FzfLuaCursorLine", { bg = row })
  hl(0, "FzfLuaCursorLineNr", { fg = p.accent, bg = row, bold = true })
  hl(0, "FzfLuaScrollBorderFull", { fg = p.accent, bg = pane })
  hl(0, "FzfLuaScrollFloatFull", { bg = p.accent })

  -- Colors handed to the fzf process itself (`fzf_colors = true` below).
  hl(0, "FzfLuaFzfNormal", { fg = p.fg })
  hl(0, "FzfLuaFzfCursorLine", { fg = p.fg, bg = row })
  hl(0, "FzfLuaFzfMatch", { fg = p.accent, bold = true })
  hl(0, "FzfLuaFzfBorder", { fg = rim })
  hl(0, "FzfLuaFzfScrollbar", { fg = p.accent })
  hl(0, "FzfLuaFzfSeparator", { fg = rim })
  hl(0, "FzfLuaFzfGutter", { bg = pane })
  hl(0, "FzfLuaFzfHeader", { fg = p.muted })
  hl(0, "FzfLuaFzfInfo", { fg = p.muted })
  hl(0, "FzfLuaFzfPointer", { fg = p.accent })
  hl(0, "FzfLuaFzfMarker", { fg = p.pink })
  hl(0, "FzfLuaFzfSpinner", { fg = p.accent })
  hl(0, "FzfLuaFzfPrompt", { fg = p.accent, bold = true })
  hl(0, "FzfLuaFzfQuery", { fg = p.fg })

  hl(0, "FzfLuaHeaderBind", { fg = p.yellow })
  hl(0, "FzfLuaHeaderText", { fg = p.muted })
  hl(0, "FzfLuaBufName", { fg = p.accent })
  hl(0, "FzfLuaBufNr", { fg = p.muted })
  hl(0, "FzfLuaTabTitle", { fg = p.accent, bold = true })
  hl(0, "FzfLuaDirPart", { fg = p.muted })
  hl(0, "FzfLuaFilePart", { fg = p.fg })
  hl(0, "FzfLuaLivePrompt", { fg = p.accent })
end

--- Picker title as an accent chip: " Files ".
---@param text string
local function title(text) return { winopts = { title = " " .. text .. " " } } end

--- `require("fzf-lua")[name](opts)` as a key handler.
local function pick(name, opts)
  return function() require("fzf-lua")[name](opts or {}) end
end

return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>ff", pick("files", title("Files")), desc = "Find files (workspace)" },
    { "<leader>fg", pick("live_grep", title("Grep")), desc = "Grep (workspace)" },
    { "<leader>fw", pick("grep_cword", title("Word")), desc = "Grep word under cursor" },
    { "<leader>fw", pick("grep_visual", title("Selection")), mode = "v", desc = "Grep selection" },
    { "<leader>fr", pick("oldfiles", title("Recent")), desc = "Recent files" },
    { "<leader>fb", pick("buffers", title("Buffers")), desc = "Buffers" },
    { "<leader>fh", pick("helptags", title("Help")), desc = "Help tags" },
    { "<leader>fk", pick("keymaps", title("Keymaps")), desc = "Keymaps" },
    { "<leader>fc", pick("commands", title("Commands")), desc = "Commands" },
    { "<leader>fd", pick("diagnostics_workspace", title("Diagnostics")), desc = "Diagnostics" },
    { "<leader>fs", pick("lsp_document_symbols", title("Symbols")), desc = "Document symbols" },
    { "<leader>f/", pick("blines", title("Buffer")), desc = "Search in buffer" },
    { "<leader>fR", pick("resume"), desc = "Resume last picker" },
    { "<leader>fz", pick("zoxide", title("zoxide")), desc = "zoxide: jump to folder" },
  },

  opts = function()
    local actions = require("fzf-lua.actions")

    return {
      -- Hand fzf the FzfLuaFzf* groups above instead of its own palette.
      fzf_colors = true,

      winopts = {
        height = 0.85,
        width = 0.85,
        row = 0.4,
        border = "rounded",
        title_pos = "center",
        backdrop = 100, -- no dimming sheet: it would cover the terminal's blur
        preview = {
          border = "rounded",
          layout = "flex", -- side by side when wide, stacked when narrow
          flip_columns = 130,
          horizontal = "right:55%",
          vertical = "down:45%",
          scrollbar = "float",
          title_pos = "center",
          winopts = { number = true, cursorline = true },
        },
      },

      fzf_opts = {
        ["--layout"] = "reverse", -- prompt on top, like the NeonPane pickers
        ["--info"] = "inline-right",
        ["--marker"] = "▍",
        ["--pointer"] = "▍",
      },

      keymap = {
        builtin = {
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
          ["<M-p>"] = "toggle-preview",
        },
        fzf = {
          ["ctrl-q"] = "select-all+accept", -- everything to the quickfix list
        },
      },

      actions = {
        files = {
          ["enter"] = actions.file_edit_or_qf,
          ["ctrl-s"] = actions.file_split,
          ["ctrl-v"] = actions.file_vsplit,
          ["ctrl-t"] = actions.file_tabedit,
          ["alt-q"] = actions.file_sel_to_qf,
          -- Same scope toggles NeonPane's Telescope pickers had.
          ["alt-h"] = actions.toggle_hidden,
          ["alt-i"] = actions.toggle_ignore,
        },
      },

      files = { cwd_prompt = false, prompt = "  " },
      grep = { prompt = "  ", rg_glob = true },
      oldfiles = { include_current_session = true, cwd_only = false },
      buffers = { sort_lastused = true },
      lsp = {
        jump1 = true, -- one result: jump straight there, like `gd` should
        code_actions = {
          -- A diff of what the action would change, before you apply it.
          previewer = "codeaction",
          winopts = { title = " Code actions " },
        },
      },
    }
  end,

  config = function(_, opts)
    local fzf = require("fzf-lua")
    fzf.setup(opts)

    -- vim.ui.select (LSP pickers, plugin prompts) through fzf-lua as well.
    fzf.register_ui_select(function(_, items)
      local height = math.min(#items + 4, math.floor(vim.o.lines * 0.6))
      return { winopts = { height = height, width = 0.5, row = 0.4, title = " Select " } }
    end)

    local ui = require("core.ui")
    apply_highlights()
    ui.on_theme_change(ui.create_augroup("NeonFzfLuaHighlights"), apply_highlights)
  end,
}
