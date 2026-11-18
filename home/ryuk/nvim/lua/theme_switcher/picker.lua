-- Theme picker on fzf-lua, with live preview.
--
-- NeonPane's picker was built on Telescope; this is the same idea on fzf-lua:
--   * every row shows the theme's 8-color swatch, drawn with 24-bit ANSI
--   * moving the cursor previews the theme across the whole editor
--   * <Enter> applies and remembers it, <Esc> puts the previous theme back
--
-- How the live preview works: fzf runs the `preview` command on every cursor
-- move. `shell.stringify_data` turns a Lua function into such a command that
-- calls back into this Neovim, so "preview" here means "apply without saving"
-- instead of drawing anything into a preview pane (which is why that pane is
-- given a width of 0).

local M = {}

local ESC = string.char(27)

--- "#rrggbb" → ANSI true-color foreground sequence.
---@param hex string
---@return string
local function fg(hex)
  local r, g, b = hex:match("^#(%x%x)(%x%x)(%x%x)$")
  if not r then
    return ""
  end
  return ("%s[38;2;%d;%d;%dm"):format(ESC, tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
end

--- Eight colored blocks for a theme's palette.
---@param palette string[]
---@return string
local function swatch(palette)
  local parts = {}
  for i = 1, 8 do
    local color = palette and palette[i]
    parts[#parts + 1] = color and (fg(color) .. "██") or "  "
  end
  return table.concat(parts) .. ESC .. "[0m"
end

--- Remove ANSI sequences (fzf usually strips them for `{}`, but not always).
---@param text string
---@return string
local function strip_ansi(text) return (text:gsub(ESC .. "%[[%d;]*m", "")) end

function M.open()
  local ok_fzf, fzf = pcall(require, "fzf-lua")
  if not ok_fzf then
    vim.notify("fzf-lua is not installed", vim.log.levels.ERROR)
    return
  end

  local shell = require("fzf-lua.shell")
  local switcher = require("theme_switcher")
  local registry = require("theme_switcher.themes")

  local original = switcher.current_id()
  local previewed = nil

  -- Display line → theme id. The name is the last field of every row.
  local by_name = {}
  local lines = {}

  -- Current theme first, so the cursor starts on it.
  local themes = vim.deepcopy(registry.get_all())
  table.sort(themes, function(a, b) return a.id == original and b.id ~= original end)

  for _, theme in ipairs(themes) do
    local marker = theme.id == original and "● " or "  "
    by_name[theme.name] = theme.id
    lines[#lines + 1] = ("%s  %s%s"):format(swatch(theme.palette), marker, theme.name)
  end

  --- Theme id for an fzf line.
  ---@param line string|nil
  ---@return string|nil
  local function id_of(line)
    if type(line) ~= "string" then
      return nil
    end
    local name = vim.trim(strip_ansi(line):gsub("^[█%s]+", ""):gsub("^●%s*", ""))
    return by_name[name]
  end

  fzf.fzf_exec(lines, {
    prompt = "  ",
    winopts = {
      title = " Themes ",
      height = math.min(#lines + 4, 20),
      width = math.min(60, vim.o.columns - 4),
      row = 0.35,
      -- Fired whenever the window closes. If the picker was dismissed, put
      -- the original theme back; after <Enter> the default action below runs
      -- next and wins, because theme applies are queued in order.
      on_close = function()
        if previewed and previewed ~= original then
          switcher.apply(original, { persist = false, preview = true })
        end
      end,
    },
    fzf_opts = {
      ["--ansi"] = true,
      ["--no-sort"] = true,
      -- The preview pane must exist (nohidden) for fzf to run the preview
      -- command, but it needs no width: the "preview" is the editor itself.
      ["--preview-window"] = "nohidden:right:0",
    },
    preview = shell.stringify_data(function(selected)
      local id = id_of(selected and selected[1])
      if id and id ~= previewed then
        previewed = id
        switcher.apply(id, { persist = false, preview = true })
      end
      return ""
    end, {}, "{}"),
    actions = {
      ["default"] = function(selected)
        local id = id_of(selected and selected[1])
        if id then
          switcher.apply(id)
          vim.notify("Theme: " .. id, vim.log.levels.INFO)
        end
      end,
    },
  })
end

return M
