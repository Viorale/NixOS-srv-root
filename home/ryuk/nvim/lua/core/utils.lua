-- Shared utility functions used across the config.
-- Avoids duplicating logic in init.lua, tabline.lua, etc.

local M = {}
local uv = vim.uv or vim.loop

local function normalize_path(path)
  if type(path) ~= "string" or path == "" then
    return nil
  end

  if vim.fs and type(vim.fs.normalize) == "function" then
    return vim.fs.normalize(path)
  end

  return path:gsub("\\", "/")
end

local function home_dir()
  local home = normalize_path(vim.env.HOME)

  if home then
    return home
  end

  if uv and type(uv.os_homedir) == "function" then
    return normalize_path(uv.os_homedir())
  end

  return normalize_path(vim.fn.expand("~")) or "."
end

--- Safely close a buffer, moving windows to an alternate buffer first.
---@param bufnr number
---@param force? boolean
function M.safe_bufdelete(bufnr, force)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local windows = vim.fn.win_findbuf(bufnr)
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_is_valid(win) then
      local alt = vim.fn.bufnr("#")
      if alt > 0 and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buflisted then
        pcall(vim.api.nvim_win_set_buf, win, alt)
      else
        local scratch = vim.api.nvim_create_buf(true, false)
        pcall(vim.api.nvim_win_set_buf, win, scratch)
      end
    end
  end

  local ok = pcall(vim.api.nvim_buf_delete, bufnr, { force = force or false })
  if not ok then
    vim.notify("Could not close buffer (unsaved changes?)", vim.log.levels.WARN)
  end
end

--- Close every listed buffer except the current one.
---@param force? boolean
function M.close_other_buffers(force)
  local current = vim.api.nvim_get_current_buf()

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      M.safe_bufdelete(buf, force)
    end
  end
end

--- Absolute path to an external tool on PATH, or `nil` when it is missing —
--- the signal to skip whatever feature needed it rather than spawn a command
--- that isn't there.
---
--- On NixOS every tool comes from Home Manager (`programs.neovim.extraPackages`
--- in home/ryuk/nvim.nix), so PATH is the only place to look. NeonPane also
--- searched Mason's bin dir and winget's package store here.
---@param name string
---@return string|nil
function M.tool_path(name)
  local system = vim.fn.exepath(name)
  return system ~= "" and system or nil
end

--- Kept for callers written against NeonPane's API; with PATH as the only
--- source there is nothing left to add to it.
---@param name string
---@return string|nil
function M.ensure_on_path(name) return M.tool_path(name) end

M.home = home_dir()

return M
