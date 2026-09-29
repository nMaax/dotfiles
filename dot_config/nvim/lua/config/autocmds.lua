-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Enable visual line wrapping in diff mode
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "VimEnter", "OptionSet" }, {
  group = vim.api.nvim_create_augroup("diff_wrap", { clear = true }),
  callback = function()
    if vim.wo.diff then
      vim.wo.wrap = true
    end
  end,
})
