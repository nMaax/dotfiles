-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("matugen").setup()

-- Send cuts (x) in black-hole instead of clipboard
vim.keymap.set({ "n", "v" }, "x", '"_x', { noremap = true })
