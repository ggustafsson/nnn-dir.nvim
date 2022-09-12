-- nnn-dir.nvim - v0.2.0
--
--   |V\_      __      _   _ _____ _____ ______        __
--   /. \\     \ \    | \ | | ____|_   _|  _ \ \      / /
--  (;^; ||     \ \   |  \| |  _|   | | | |_) \ \ /\ / /
--    /___3     / /   | |\  | |___  | | |  _ < \ V  V /
--   (___n))   /_/    |_| \_|_____| |_| |_| \_\ \_/\_/
--
-- Nvim plugin that replaces builtin Netrw with external file manager nnn.
--
-- Author: Göran Gustafsson (gustafsson.g at gmail.com)
-- License: BSD 3-Clause

local M = {}
local plug_name = "nnn-dir" -- Used for augroup, require(), etc.

local dir_file = os.getenv("NNN_TMPFILE") or
  (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") ..
  "/nnn/.lastd"                       -- nnn last directory file.
local sel_file = vim.fn.tempname()    -- nnn selection file.
local nnn_cmd = "nnn -p " .. sel_file -- nnn picker mode.

-- Default window switching keybindings. See ":help window-move-cursor".
local mappings = {
  "<C-W>h", "<C-W><C-H>",
  "<C-W>j", "<C-W><C-J>",
  "<C-W>k", "<C-W><C-K>",
  "<C-W>l", "<C-W><C-L>",
  "<C-W>w", "<C-W><C-W>",
  "<C-W>W",
}

-- Set autocmds needed for correct terminal window behaviour.
local function set_autocmds()
  -- Reuse group for multitasking. Buffer limited autocmds clears themselves.
  local group = vim.api.nvim_create_augroup(plug_name .. "-term", {
    clear = false
  })
  -- Auto-insert when entering terminal window.
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    buffer = vim.api.nvim_get_current_buf(),
    callback = function()
      vim.cmd("startinsert")
    end
  })
end

-- Set local window switching keybindings in terminal window.
local function set_local_keymaps()
  for _, key in ipairs(mappings) do
    vim.api.nvim_buf_set_keymap(0, "t", key, "<C-\\><C-N>" .. key, {})
  end
end

-- Set global keybindings. Used for Netrw related bindings.
local function set_global_keymaps()
  -- Do not override existing user keybinding.
  if vim.fn.maparg("gx", "n") == "" then
    if vim.fn.has("mac") then
      vim.api.nvim_set_keymap("n", "gx", ':silent !open "<cfile>"<CR>', {
        noremap = true
      })
    elseif vim.fn.has("unix") and vim.fn.executable("xdg-open") then
      vim.api.nvim_set_keymap("n", "gx", ':silent !xdg-open "<cfile>"<CR>', {
        noremap = true
      })
    end
  end
end

-- Set miscellaneous settings in terminal window.
local function set_local_options()
  vim.api.nvim_set_option_value("number", false, { scope = "local" })
  vim.api.nvim_set_option_value("relativenumber", false, { scope = "local" })
  vim.api.nvim_set_option_value("signcolumn", "no", { scope = "local" })
end

-- Initialize nnn directory hijack setup.
local function setup_hijack()
  -- Prevent Netrw plugin from loading.
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  -- Start plugin if new buffer is of type directory.
  local group = vim.api.nvim_create_augroup(plug_name .. "-hijack", {})
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function()
      local buf_name = vim.api.nvim_buf_get_name(0)
      local stat = vim.loop.fs_stat(buf_name)
      if stat == nil or stat.type ~= "directory" then
        return
      end

      local buf_id = vim.api.nvim_get_current_buf()
      local path = vim.api.nvim_eval("fnameescape(expand('%:p:h'))")
      require(plug_name).start(path)
      vim.api.nvim_buf_delete(buf_id, {}) -- Previous directory buffer.
    end
  })
end

-- Handle terminal exit actions. Change directory, open files, etc.
local function on_exit()
  -- 1. Change current directory if "NNN_TMPFILE" file exists.
  local file, _ = io.open(dir_file, "r")
  if file then
    local dir = file:read():sub(5, -2) -- Content: cd "x"
    vim.cmd("tcd " .. vim.fn.fnameescape(dir))
    file:close()
    os.remove(dir_file)
  end

  -- 2. Close terminal silently if no files are selected.
  local stat = vim.loop.fs_stat(sel_file)
  if stat == nil then
    vim.api.nvim_buf_delete(0, {}) -- Skip "[Process exited 0]" step.
    return
  end

  -- 3. Open all selected items of type file.
  local buf_id = vim.api.nvim_get_current_buf()
  for file in io.lines(sel_file) do
    local stat = vim.loop.fs_stat(file)
    if stat ~= nil and stat.type == "file" then
      vim.cmd("edit " .. vim.fn.fnameescape(file))
    end
  end
  vim.api.nvim_buf_delete(buf_id, {}) -- Skip "[Process exited 0]" step.
end

-- Initialize terminal window and execute nnn.
local function init_nnn(path)
  local cmd = nnn_cmd -- Static variable.
  if path ~= nil then
    cmd = nnn_cmd .. " " .. path -- Set outside of block scope.
  end
  vim.cmd("enew")
  vim.api.nvim_buf_set_option(0, "buflisted", false)
  vim.fn.termopen(cmd, { on_exit = on_exit })
  vim.cmd("startinsert")
end

-- Enable plugin. Intended for use in init.lua / init.vim.
function M.setup()
  setup_hijack()
  set_global_keymaps()
end

-- Execute plugin. Not intended for manual use.
function M.start(path)
  init_nnn(path)
  set_autocmds()
  set_local_keymaps()
  set_local_options()
end

return M
