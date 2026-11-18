-- Treesitter, plus the structural text objects and motions built on it.
--
-- Both plugins track their `main` branch — the rewrite that Neovim 0.12 needs
-- (NeonPane pinned the old `master` branch, which no longer loads on 0.12).
-- What changed, in short:
--   * nvim-treesitter only installs parsers now. Highlighting and indent are
--     switched on per buffer below (FileType autocmd), not via `configs.setup`.
--   * Parsers are built with the `tree-sitter` CLI (>= 0.26.1) and a C
--     compiler — both come from extraPackages in home/ryuk/nvim.nix.
--   * The plugin does not support lazy-loading, hence `lazy = false`.
--   * Incremental selection is gone; flash.nvim's treesitter select (`S`)
--     covers it.

-- Selection text objects, as `{ lhs, query, description }`.
local SELECT = {
  { "af", "@function.outer", "a function" },
  { "if", "@function.inner", "inner function" },
  { "ac", "@class.outer", "a class" },
  { "ic", "@class.inner", "inner class" },
  { "aa", "@parameter.outer", "an argument" },
  { "ia", "@parameter.inner", "inner argument" },
  { "ai", "@conditional.outer", "a conditional" },
  { "ii", "@conditional.inner", "inner conditional" },
  { "al", "@loop.outer", "a loop" },
  { "il", "@loop.inner", "inner loop" },
  { "a/", "@comment.outer", "a comment" },
}

-- Motions, as `{ suffix, query, noun }` — each becomes a `]x` / `[x` pair.
--
-- Class motions use `]C`/`[C`, not `]c`/`[c`: the lowercase pair is Vim's
-- native "next change" and belongs to gitsigns here.
local MOVE = {
  { "f", "@function.outer", "function" },
  { "C", "@class.outer", "class" },
  { "a", "@parameter.inner", "argument" },
}

-- Parsers installed up front: the languages this machine is set up for.
-- Anything else is installed automatically the first time you open it.
local PARSERS = {
  -- Neovim / config
  "lua", "luadoc", "vim", "vimdoc", "query",
  -- NixOS, niri (KDL), shell, data formats
  "nix", "kdl", "bash", "regex", "json", "yaml", "toml", "xml", "dockerfile", "ini",
  -- Git
  "diff", "git_config", "git_rebase", "gitcommit", "gitignore",
  -- Prose (Obsidian notes)
  "markdown", "markdown_inline",
  -- Code
  "python", "c", "html", "css", "javascript",
}

--- Start Treesitter highlighting + indent for a buffer, if a parser exists.
---@param buf integer
local function attach(buf)
  -- Treesitter on a minified bundle is pathologically slow.
  local ok_stat, stat = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
  if ok_stat and stat and stat.size > 200 * 1024 then
    return
  end

  if pcall(vim.treesitter.start, buf) then
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    -- Structural text objects: `vif` (inner function), `dac` (a class), and
    -- the `]f` / `[f` style motions below.
    { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
  },
  config = function()
    local ts = require("nvim-treesitter")
    ts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

    -- Async; a no-op for parsers that are already there.
    if vim.fn.executable("tree-sitter") == 1 then
      ts.install(PARSERS)
    else
      vim.notify("tree-sitter CLI missing: parsers can't be built (see :checkhealth core)", vim.log.levels.WARN)
    end

    local available = nil
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("NeonTreesitter", { clear = true }),
      callback = function(event)
        local lang = vim.treesitter.language.get_lang(event.match) or event.match

        if vim.list_contains(ts.get_installed("parsers"), lang) then
          attach(event.buf)
          return
        end

        -- Auto-install: parser known to nvim-treesitter but not installed yet.
        available = available or ts.get_available()
        if vim.list_contains(available, lang) and vim.fn.executable("tree-sitter") == 1 then
          ts.install({ lang }):await(function()
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(event.buf) then
                attach(event.buf)
              end
            end)
          end)
        end
      end,
    })

    -- Buffers opened before this ran (e.g. `nvim file.lua`).
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
        attach(buf)
      end
    end

    local ok, textobjects = pcall(require, "nvim-treesitter-textobjects")    if not ok then
      return
    end

    textobjects.setup({
      select = { lookahead = true }, -- jump forward to the next object if not inside one
      move = { set_jumps = true }, -- so <C-o> comes back
    })

    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")
    local swap = require("nvim-treesitter-textobjects.swap")
    local repeatable = require("nvim-treesitter-textobjects.repeatable_move")

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
    end

    -- Text objects. Visual and operator-pending only: `af` in normal mode is
    -- not a motion, and mapping it there would shadow nothing useful anyway.
    for _, entry in ipairs(SELECT) do
      local lhs, query, desc = entry[1], entry[2], entry[3]
      map({ "x", "o" }, lhs, function() select.select_textobject(query, "textobjects") end, desc)
    end

    -- Motions. `move.goto_*` is already wrapped in the plugin's
    -- `make_repeatable_move`, so `;` / `,` below pick these up for free.
    for _, entry in ipairs(MOVE) do
      local suffix, query, noun = entry[1], entry[2], entry[3]
      map(
        { "n", "x", "o" },
        "]" .. suffix,
        function() move.goto_next_start(query, "textobjects") end,
        "Next " .. noun
      )
      map(
        { "n", "x", "o" },
        "[" .. suffix,
        function() move.goto_previous_start(query, "textobjects") end,
        "Previous " .. noun
      )
    end

    -- Reorder arguments without retyping them.
    map("n", "<leader>cs", function() swap.swap_next("@parameter.inner") end, "Swap argument next")
    map(
      "n",
      "<leader>cS",
      function() swap.swap_previous("@parameter.inner") end,
      "Swap argument previous"
    )

    -- `;` / `,` repeat the motions above. flash.nvim leaves these keys alone on
    -- purpose (see the note on `modes.char.keys` in plugins/flash.lua): its own
    -- `f`/`t` motions repeat with clever-f, so the repeat pair is free for the
    -- structural motions, which have no other way to repeat.
    map({ "n", "x", "o" }, ";", repeatable.repeat_last_move_next, "Repeat last motion forward")
    map({ "n", "x", "o" }, ",", repeatable.repeat_last_move_previous, "Repeat last motion backward")
  end,
}
