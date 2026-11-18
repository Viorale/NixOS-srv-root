# nvim – NeonPane-Look + Template-Features, für NixOS

Diese Config verbindet zwei Repos:

| Herkunft | Was übernommen wurde |
|---|---|
| [W-gerber/NeonPane.nvim](https://github.com/W-gerber/NeonPane.nvim) (MIT, siehe `LICENSE`) | **Aussehen**: base46-Themes (neon commit, neon vommit, …), Glas-Transparenz, Pill-Tabline, Bubble-Statusline, Neo-tree-Seitenbaum, which-key-/noice-Styling |
| [greggh/neovim-config-template](https://github.com/greggh/neovim-config-template) | **Feature-Liste**: lazy.nvim, blink.cmp, Trouble, Noice, which-key, Treesitter, LSP, Lazygit, Toggleterm, smart-splits, ccc, flash, autopairs, mini.surround, todo-comments, Profiling |
| neu | **yazi.nvim** statt Snacks-Explorer, **fzf-lua** statt Telescope, LSP/Tools über **Nix** statt Mason |

## Aufbau

```
init.lua                 Einstieg: lazy.nvim laden, UI starten
lua/
  core/                  Optionen, Keymaps, Autocmds, Farben (ui.lua), Glas (transparency.lua)
  plugins/               ein Plugin pro Datei, Liste in plugins/init.lua
  themes/                base46-Themes (neon_commit.lua, neon_vommit.lua, …)
  theme_switcher/        Theme-Liste + fzf-lua-Picker mit Live-Vorschau
  statusline.lua         lualine "bubbles"
  tabline.lua            Pill-Tabs oben
  nvconfig.lua           base46-Einstellungen (Standard-Theme)
```

**Eine Regel:** UI-Code nutzt nie feste Farben, sondern `require("core.ui").palette()`.
Deshalb färbt ein Theme-Wechsel Statusleiste, Tabs, Picker, yazi-Rahmen und
Completion-Menü automatisch mit um.

## Wichtigste Tasten (Leader = Leertaste, `<Tab>` zeigt alle)

| Taste | Was |
|---|---|
| `<leader>up` | Theme-Picker (Pfeiltasten = Live-Vorschau, Enter = übernehmen, Esc = zurück) |
| `<leader>ub` | Glas-Transparenz an/aus |
| `<leader>e` | Neo-tree (Seitenbaum) |
| `<leader>-` / `<leader>fe` | yazi bei der aktuellen Datei |
| `<leader>fE` | yazi im Projektordner |
| `<leader>ff` / `fg` / `fb` / `fr` | Dateien / Grep / Buffer / Zuletzt geöffnet (fzf-lua) |
| `<leader>fo` | Projektordner wechseln (zoxide-Liste) |
| `gd` `gr` `gi` `K` | LSP: Definition, Referenzen, Implementierung, Doku |
| `<leader>ca` | Code-Actions mit Diff-Vorschau |
| `<leader>xx` | Trouble (alle Diagnosen) |
| `<leader>gl` | Lazygit |
| `<C-h/j/k/l>` | Fenster wechseln (auch in tmux-Panes) |
| `<leader>uc` | Farbwähler (ccc) |
| `<leader>Lp` | Startzeit-Profil (`:Lazy profile`) |

## Prüfen

```vim
:checkhealth core     " Werkzeuge, Compiler, tree-sitter, Theme-Cache
:checkhealth yazi
:Lazy                 " Plugins
```
