vim.g.mapleader = " "
-- Project view
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Refresh buffer
vim.keymap.set("n", "<leader>R", "<cmd>checktime<CR>", { desc = "Check files changed on disk" })

-- Replace word at cursor
vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- Show errors, warnings and info
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })

-- Search navigation with centering
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

