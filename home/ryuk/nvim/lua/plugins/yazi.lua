-- yazi.nvim: the yazi file manager in a floating window. Replaces the
-- template's Snacks explorer for real file work (copy, move, rename, bulk
-- rename, previews); Neo-tree stays as the always-visible side tree.
--
-- yazi has its own theme ("flavor"), configured in yazi itself — on this
-- machine catppuccin/nix themes it. Only the floating window's border comes
-- from Neovim, so that is all that follows the NeonPane palette here.
--
-- Inside yazi (yazi.nvim defaults):
--   <C-v> / <C-x> / <C-t>  open in vsplit / split / new tab
--   <C-s>                  grep in the hovered directory (fzf-lua)
--   <C-g>                  find files in the hovered directory (fzf-lua)
--   <tab>                  jump to the hovered file's buffer in Neovim
--   <C-y>                  copy the hovered file's path (relative)
--   F1                     show all yazi.nvim keys

local function apply_highlights()
  local ui = require("core.ui")
  local p = ui.palette()
  local rim = vim.g.ui_transparent and ui.blend(p.accent, p.bg, 0.45) or ui.blend(p.accent, p.bg, 0.35)

  vim.api.nvim_set_hl(0, "YaziFloat", { fg = p.fg, bg = ui.pane_bg(0.1) })
  vim.api.nvim_set_hl(0, "YaziFloatBorder", { fg = rim, bg = ui.pane_bg(0.1) })
end

return {
  "mikavilpas/yazi.nvim",
  version = "*", -- latest release
  event = "VeryLazy",
  dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
  keys = {
    { "<leader>-", "<cmd>Yazi<cr>", mode = { "n", "v" }, desc = "yazi (current file)" },
    { "<leader>fe", "<cmd>Yazi<cr>", desc = "yazi (current file)" },
    { "<leader>fE", "<cmd>Yazi cwd<cr>", desc = "yazi (workspace)" },
    { "<leader>fl", "<cmd>Yazi toggle<cr>", desc = "Resume yazi" },
  },

  ---@type YaziConfig | {}
  opts = {
    -- Neo-tree already takes over `nvim <dir>`; two plugins racing for the
    -- same directory buffer is how you get an empty window.
    open_for_directories = false,
    floating_window_scaling_factor = 0.85,
    yazi_floating_window_border = "rounded",
    yazi_floating_window_winblend = 0,
    -- The <C-s>/<C-g> handoffs inside yazi go to fzf-lua, not Telescope.
    integrations = {
      grep_in_directory = "fzf-lua",
      grep_in_selected_files = "fzf-lua",
    },
    keymaps = { show_help = "<f1>" },
  },

  config = function(_, opts)
    require("yazi").setup(opts)

    local ui = require("core.ui")
    apply_highlights()
    ui.on_theme_change(ui.create_augroup("NeonYaziHighlights"), apply_highlights)
  end,
}
