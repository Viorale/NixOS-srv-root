-- smart-splits.nvim (from the template): move between and resize splits with
-- one set of keys — and, because you use tmux, those same keys carry on into
-- the neighbouring tmux pane when there is no split left in that direction.
--
-- For the tmux half, tmux needs the matching bindings (see the smart-splits
-- README, "Multiplexer integration"); without them the keys simply stop at the
-- edge of Neovim, which is also fine.

local function ss(fn, ...)
  local args = { ... }
  return function() require("smart-splits")[fn](unpack(args)) end
end

return {
  "mrjones2014/smart-splits.nvim",
  version = "*",
  lazy = false, -- must be loaded for the tmux side to detect Neovim
  keys = {
    -- Move (Alt+hjkl in core/keymaps.lua does the same and also works from a
    -- terminal buffer).
    { "<C-h>", ss("move_cursor_left"), desc = "Window: left" },
    { "<C-j>", ss("move_cursor_down"), desc = "Window: down" },
    { "<C-k>", ss("move_cursor_up"), desc = "Window: up" },
    { "<C-l>", ss("move_cursor_right"), desc = "Window: right" },

    -- Resize
    { "<C-Left>", ss("resize_left"), desc = "Window: resize left" },
    { "<C-Down>", ss("resize_down"), desc = "Window: resize down" },
    { "<C-Up>", ss("resize_up"), desc = "Window: resize up" },
    { "<C-Right>", ss("resize_right"), desc = "Window: resize right" },

    -- Swap the buffer with the neighbouring split
    { "<leader>sH", ss("swap_buf_left"), desc = "Swap buffer left" },
    { "<leader>sJ", ss("swap_buf_down"), desc = "Swap buffer down" },
    { "<leader>sK", ss("swap_buf_up"), desc = "Swap buffer up" },
    { "<leader>sL", ss("swap_buf_right"), desc = "Swap buffer right" },
  },
  opts = {
    ignored_filetypes = { "neo-tree", "trouble", "lazy", "yazi" },
    ignored_buftypes = { "nofile", "quickfix", "prompt" },
    resize = { amount = 3 },
    move = { at_edge = "wrap" },
    -- Outside tmux there is simply no multiplexer; that's not worth a warning.
    mux = { warn_if_unusable = false },
  },
}
