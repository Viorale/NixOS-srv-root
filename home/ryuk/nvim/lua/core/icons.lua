-- Central icon table (Nerd Font v3).
--
-- Glyphs are written as `\u{...}` escapes on purpose: the raw characters live in
-- the Unicode private-use area, and plenty of tools (diff viewers, editors,
-- clipboards, AI assistants) silently drop them, which leaves blank icons behind.
-- Escapes survive all of that and are greppable.
--
-- Requires a Nerd Font in the terminal: https://www.nerdfonts.com

return {
  -- Diagnostics (sign column, statusline, Trouble)
  diagnostics = {
    error = "\u{f057}", -- nf-fa-times_circle
    warn = "\u{f071}", -- nf-fa-exclamation_triangle
    info = "\u{f05a}", -- nf-fa-info_circle
    hint = "\u{f0335}", -- nf-md-lightbulb_on
  },

  -- Git / diff
  git = {
    branch = "\u{e0a0}", -- powerline branch
    added = "\u{f067}", -- plus
    modified = "\u{f444}", -- filled dot
    removed = "\u{f068}", -- minus
    -- Nerd Fonts v3 moved the Octicons block. `\u{f554}` was
    -- `nf-oct-diff_renamed` under v2 and is unassigned in v3, so it rendered as
    -- a replacement box in Neo-tree's git column. This is the same glyph at its
    -- current codepoint.
    renamed = "\u{f45a}", -- nf-oct-diff_renamed
    -- "?" for untracked is the git convention (and what `git status --short`
    -- prints), so this is meant to be a question mark. It was the FontAwesome
    -- one while everything around it is an Octicon; this is the Octicon.
    untracked = "\u{f420}", -- nf-oct-question
    ignored = "\u{f474}", -- nf-oct-diff_ignored
  },

  -- Files / buffers
  file = {
    modified = "\u{25cf}", -- ●
    readonly = "\u{f023}", -- lock
    new = "\u{f016}", -- file outline
    folder = "\u{e5ff}", -- closed folder
    folder_open = "\u{e5fe}",
    -- `\u{f414}` is `nf-oct-file_submodule` in v3 — a submodule marker, not an
    -- empty folder. It is a real glyph, so it drew fine and drew the wrong thing.
    folder_empty = "\u{f0256}", -- nf-md-folder_outline
  },

  -- Chrome / decorations
  ui = {
    pill_left = "\u{e0b6}", -- ◖ rounded left edge
    pill_right = "\u{e0b4}", -- ◗ rounded right edge
    ellipsis = "\u{2026}", -- …
    clock = "\u{f017}",
    home = "\u{f015}",
    search = "\u{f0349}",
    caret = "\u{258e}", -- ▎
    chevron_right = "\u{f0142}",
    chevron_down = "\u{f0140}",
    separator = "\u{2502}", -- │
  },

}
