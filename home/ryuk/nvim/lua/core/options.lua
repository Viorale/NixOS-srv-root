-- Editor options. Keep this file declarative: no keymaps, no autocommands.

local opt = vim.opt

-- Leader keys must be set before any mapping that uses them.
--
-- Space stays the leader, so every `<leader>x` sequence keeps working as it
-- always has. core/keymaps.lua adds Tab as a second way into the same tree.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Providers we don't use (silences :checkhealth noise and saves startup work).
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Prefer an explicit Python 3 host when one is on PATH — but not now.
--
-- `exepath()` is the single most expensive call in this file: on Windows it
-- walks every PATH entry against every PATHEXT extension, measured here at
-- ~15ms against a 70-entry PATH, which was roughly 18% of total startup. What
-- it buys is a variable nothing reads until a `:python3` command or `py3eval()`
-- runs, and neither can happen before the UI is up.
--
-- So it moves to VeryLazy: same value, same behaviour, off the critical path.
-- Not simply deleted (the way the three providers below are) because the
-- provider itself stays enabled, and leaving the host unset would make Neovim
-- rediscover it the slow way on first use.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local python3 = vim.fn.exepath("python3")
    if python3 == "" then
      python3 = vim.fn.exepath("python")
    end
    if python3 ~= "" then
      vim.g.python3_host_prog = python3
    end
  end,
})

-- UI ------------------------------------------------------------------------
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.showmode = false -- the statusline already shows the mode
opt.cursorline = true
opt.signcolumn = "yes" -- reserve the gutter so diagnostics don't shift text
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true -- wrap at word boundaries when wrap is turned on
opt.pumheight = 12 -- keep the completion menu from swallowing the screen
opt.pumblend = 0
opt.winborder = "rounded" -- default border for floats (hover, LSP, pickers)
opt.laststatus = 3 -- single global statusline
opt.cmdheight = 1
opt.fillchars = {
  eob = " ", -- no "~" past the end of the buffer
  fold = " ",
  foldopen = "\u{25be}", -- ▾
  foldclose = "\u{25b8}", -- ▸
  foldsep = " ",
  diff = "\u{2571}", -- ╱
}
opt.list = true
opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

-- Splits --------------------------------------------------------------------
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen" -- don't scroll the current window when splitting

-- Search --------------------------------------------------------------------
opt.ignorecase = true
opt.smartcase = true -- ...unless the query contains an uppercase letter
opt.inccommand = "split" -- live preview for :substitute

-- Editing -------------------------------------------------------------------
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.shiftround = true
opt.autoindent = true
opt.smartindent = true
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.virtualedit = "block" -- let visual-block selections go past line ends
opt.confirm = true -- ask instead of failing when quitting with unsaved changes

-- Files / history -----------------------------------------------------------
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false
opt.updatetime = 250 -- faster CursorHold (default 4000ms)
opt.timeoutlen = 300 -- faster which-key / keymap sequences
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help" }

-- Folding (Treesitter-based, but everything starts unfolded) -----------------
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- PATH ----------------------------------------------------------------------
--
-- Nothing to do here on NixOS: language servers, formatters, linters, fzf, rg,
-- fd, yazi and gcc all come from Home Manager (home/ryuk/nvim.nix) and are on
-- PATH before Neovim starts. NeonPane hoisted Mason's bin dir and a MinGW
-- toolchain at this point; both are Windows/Mason-specific and are gone.
