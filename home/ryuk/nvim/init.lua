-- ============================================================================
-- Neovim configuration entry point.
--
--   lua/core/      editor behaviour (options, keymaps, autocmds, workspace, ...)
--   lua/plugins/   one lazy.nvim spec per plugin, aggregated by plugins/init.lua
--   lua/themes/    base46 theme definitions and per-theme overrides
--   lua/           statusline, tabline and the theme switcher
--
-- Requires Neovim 0.11+ (vim.lsp.config, vim.hl, vim.diagnostic.jump, winborder).
-- Run `:checkhealth core` to verify the external tools this config expects.
-- ============================================================================

if vim.fn.has("nvim-0.11") == 0 then
  vim.api.nvim_echo({ { "This config requires Neovim 0.11 or newer.\n", "ErrorMsg" } }, true, {})
  return
end

require("core.options")
require("core.keymaps")
require("core.autocmds")

-- How a diagnostic looks, for every producer of one (LSP, nvim-lint, ...).
-- Set up before plugins so a linter that reports before any language server has
-- attached still gets the configured appearance rather than Neovim's defaults.
require("core.diagnostics").setup()

-- Workspace (IDE-style "open folder"): :OpenFolder switches the project root,
-- picking from zoxide's list of known directories.
local workspace = require("core.workspace")

vim.api.nvim_create_user_command(
  "OpenFolder",
  function() workspace.open_dialog() end,
  { desc = "Open folder as workspace" }
)

-- ============================================================================
-- lazy.nvim bootstrap
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  if vim.fn.executable("git") == 0 then
    vim.api.nvim_echo({ { "git is required to bootstrap lazy.nvim\n", "ErrorMsg" } }, true, {})
    return
  end

  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to bootstrap lazy.nvim\n", "ErrorMsg" },
      { tostring(output or ""):gsub("%s+$", ""), "WarningMsg" },
    }, true, {})
    return
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup(require("plugins"), {
  -- On NixOS ~/.config/nvim is a read-only link into the Nix store (Home
  -- Manager), so lazy.nvim cannot write its lockfile there. Keep it with the
  -- plugins instead. Copy it into the repo when you want to pin versions.
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
  -- No plugin here needs luarocks.
  rocks = { enabled = false },
  defaults = { lazy = true, version = false },
  checker = { enabled = false },
  change_detection = { notify = false },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "rplugin",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
      },
    },
  },
})

-- ============================================================================
-- UI bring-up
-- ============================================================================

-- Transparency has to be applied immediately (before the first redraw) so the
-- terminal background isn't briefly painted over on startup.
require("core.transparency").setup()

-- The rest of the chrome loads right after the UI is drawn, so it never blocks
-- the initial render. VeryLazy fires ~10ms into startup.
--
-- Each module is started independently: one that throws reports itself and the
-- others still come up, rather than taking the whole UI down with it.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    for _, module in ipairs({ "theme_switcher", "core.chrome", "tabline" }) do
      local ok, err = pcall(function() require(module).setup() end)
      if not ok then
        vim.notify(("Failed to start %s: %s"):format(module, err), vim.log.levels.WARN)
      end
    end
  end,
})
