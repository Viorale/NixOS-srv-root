-- ccc.nvim (from the template): a color picker, plus colored backgrounds
-- behind color codes like #ff2d95 in any file — handy while editing themes in
-- lua/themes/.
--
--   <leader>uc  pick / convert the color under the cursor (CccPick)
--   <leader>uC  toggle the inline color highlighting

return {
  "uga-rosa/ccc.nvim",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "CccPick", "CccConvert", "CccHighlighterToggle" },
  keys = {
    { "<leader>uc", "<cmd>CccPick<cr>", desc = "Color picker (ccc)" },
    { "<leader>uC", "<cmd>CccHighlighterToggle<cr>", desc = "Toggle color highlighting" },
  },
  config = function()
    local ccc = require("ccc")
    ccc.setup({
      highlighter = {
        auto_enable = true,
        lsp = true,
        max_byte = 100 * 1024,
        excludes = { "lazy", "neo-tree", "yazi", "fzf" },
      },
      inputs = { ccc.input.rgb, ccc.input.hsl, ccc.input.oklch },
      outputs = { ccc.output.hex, ccc.output.hex_short, ccc.output.css_rgb, ccc.output.css_hsl },
      pickers = {
        ccc.picker.hex,
        ccc.picker.css_rgb,
        ccc.picker.css_hsl,
        ccc.picker.css_oklch,
      },
    })
  end,
}
