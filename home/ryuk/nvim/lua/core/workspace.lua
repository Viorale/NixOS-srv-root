-- Workspace handling: makes "open folder" behave like an IDE workspace.
-- The workspace root is simply Neovim's cwd; opening a folder cds into it,
-- so fzf-lua, Neo-tree, yazi, grep, LSP root detection etc. all follow along.
--
-- Changed from NeonPane: the folder picker no longer opens a Windows dialog
-- through PowerShell. It lists the directories zoxide already knows (the same
-- list your shell's `z` uses), in fzf-lua. Without zoxide it falls back to a
-- plain prompt with directory completion.

local M = {}
local utils = require("core.utils")

local function normalize(path)
  if type(path) ~= "string" or path == "" then
    return nil
  end
  local absolute = vim.fn.fnamemodify(path, ":p"):gsub("/+$", "")
  return vim.fs.normalize(absolute)
end

--- Current workspace root (always the cwd).
---@return string
function M.root() return normalize(vim.fn.getcwd()) or vim.fn.getcwd() end

--- Short display name for the current workspace (folder name).
---@return string
function M.label()
  local root = M.root()
  if root == normalize(utils.home) then
    return "Home"
  end
  local name = vim.fn.fnamemodify(root, ":t")
  return name ~= "" and name or root
end

--- Open a folder as the workspace: cd into it, root the explorer there,
--- and notify anything listening (User WorkspaceChanged).
---@param dir string
---@param opts? { explorer?: boolean }  explorer=false skips opening neo-tree
---@return boolean ok
function M.open(dir, opts)
  opts = opts or {}
  dir = normalize(dir)

  if not dir or vim.fn.isdirectory(dir) == 0 then
    vim.notify("Can't open workspace — folder not found: " .. tostring(dir), vim.log.levels.WARN)
    return false
  end

  local ok, err = pcall(vim.cmd.cd, vim.fn.fnameescape(dir))
  if not ok then
    vim.notify("Could not open workspace: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  if opts.explorer ~= false then
    pcall(function() require("neo-tree.command").execute({ action = "show", dir = dir }) end)
  end

  vim.api.nvim_exec_autocmds("User", {
    pattern = "WorkspaceChanged",
    data = { root = dir },
  })

  vim.notify("Workspace: " .. M.label(), vim.log.levels.INFO)
  return true
end

--- Fallback when zoxide or fzf-lua is missing: a prompt with dir completion.
local function prompt_folder()
  vim.ui.input({ prompt = "Open Folder: ", default = M.root() .. "/", completion = "dir" }, function(dir)
    if dir and vim.trim(dir) ~= "" then
      M.open(vim.trim(dir))
    end
  end)
end

--- Pick a folder from zoxide's database and open it as the workspace.
function M.open_dialog()
  local ok, fzf = pcall(require, "fzf-lua")
  if not ok or vim.fn.executable("zoxide") == 0 then
    prompt_folder()
    return
  end

  fzf.fzf_exec("zoxide query --list --score", {
    prompt = "Workspace> ",
    winopts = { title = " Open folder (zoxide) ", height = 0.45, width = 0.6 },
    -- Each line is "<score> <path>"; show the score dimmed, keep the path.
    fzf_opts = { ["--no-sort"] = true, ["--nth"] = "2..", ["--tiebreak"] = "end,index" },
    actions = {
      ["default"] = function(selected)
        local line = selected and selected[1]
        local dir = line and line:match("^%s*[%d%.]+%s+(.+)$")
        if dir then
          M.open(dir)
        end
      end,
      -- Ctrl-e: type a path that zoxide doesn't know yet.
      ["ctrl-e"] = function() vim.schedule(prompt_folder) end,
    },
  })
end

return M
