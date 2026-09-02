-- Gitsigns
vim.keymap.set("n", "]c", "<cmd>Gitsigns next_hunk<CR>",
  { desc = "Next Git hunk" })

vim.keymap.set("n", "[c", "<cmd>Gitsigns prev_hunk<CR>",
  { desc = "Previous Git hunk" })

vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>",
  { desc = "Preview Git hunk" })

vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<CR>",
  { desc = "Git blame line" })

vim.keymap.set("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>",
  { desc = "Git diff file" })

vim.keymap.set("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>",
  { desc = "Stage Git hunk" })

vim.keymap.set("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>",
  { desc = "Reset Git hunk" })

vim.keymap.set("n", "<leader>gS", "<cmd>Gitsigns stage_buffer<CR>",
  { desc = "Stage Git buffer" })

vim.keymap.set("n", "<leader>gR", "<cmd>Gitsigns reset_buffer<CR>",
  { desc = "Reset Git buffer" })
