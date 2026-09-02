# Neovim Summary and Shortcut Cheat Sheet

Generated from the Neovim config in this repo on 2026-09-02.

## Core Setup

- Leader key: `<Space>`
- Plugin manager: `lazy.nvim`
- Colorscheme: `tokyonight`
- LSP completion: `nvim-cmp`
- Git integration: `gitsigns.nvim` and `vim-fugitive`
- Fuzzy finding: `telescope.nvim`
- Syntax highlighting: `nvim-treesitter`
- Undo browser: `undotree`
- File/bookmark jumps: `harpoon`

## Installed Plugins

- `folke/tokyonight.nvim`
- `hrsh7th/nvim-cmp`
- `hrsh7th/cmp-nvim-lsp`
- `hrsh7th/cmp-buffer`
- `hrsh7th/cmp-path`
- `hrsh7th/cmp-nvim-lua`
- `lewis6991/gitsigns.nvim`
- `ThePrimeagen/harpoon` on branch `harpoon2`
- `nvim-lualine/lualine.nvim`
- `nvim-tree/nvim-web-devicons`
- `neovim/nvim-lspconfig`
- `nvim-telescope/telescope.nvim`
- `nvim-lua/plenary.nvim`
- `nvim-treesitter/nvim-treesitter`
- `mbbill/undotree`
- `tpope/vim-fugitive`
- `ThePrimeagen/vim-be-good`

## Global Remaps

- `<leader>pv` - open file explorer with `:Ex`
- `<leader>R` - refresh buffers with `:checktime`
- `<leader>s` - substitute the word under cursor in the file
- `<leader>e` - show diagnostics in a floating window
- `n` - next search result, centered
- `N` - previous search result, centered

## Telescope

- `<leader>pf` - find files
- `<leader>pg` - live grep
- `<leader>pe` - diagnostics picker
- `<C-p>` - git files

## Harpoon

- `<leader>a` - add current file
- `<C-e>` - toggle quick menu
- `<C-h>` - jump to slot 1
- `<C-t>` - jump to slot 2
- `<C-n>` - jump to slot 3
- `<C-s>` - jump to slot 4
- `<C-S-P>` - previous Harpoon item
- `<C-S-N>` - next Harpoon item

## Fugitive

- `<leader>fgs` - open Git status

## Gitsigns

- `]c` - next changed hunk
- `[c` - previous changed hunk
- `<leader>gp` - preview the hunk at the cursor
- `<leader>gb` - show blame for the current line
- `<leader>gd` - diff the current file against its Git version
- `<leader>gs` - stage the hunk at the cursor
- `<leader>gr` - reset the hunk at the cursor
- `<leader>gS` - stage the current buffer
- `<leader>gR` - reset the current buffer

## Undotree

- `<leader>u` - toggle undo tree

## LSP Buffer Maps

These are active after an LSP attaches to the current buffer.

- `gd` - go to definition
- `gr` - go to references
- `K` - hover documentation
- `<leader>rn` - rename symbol
- `<leader>ca` - code action

## Completion

Insert mode completion keys from `nvim-cmp`:

- `<C-Space>` - open completion
- `<CR>` - confirm selection
- `<Tab>` - next completion item
- `<S-Tab>` - previous completion item

## Treesitter Parsers

Enabled or auto-installed for:

- `bash`
- `zsh`
- `lua`
- `python`
- `javascript`
- `html`
- `css`
- `csv`
- `json`
- `dockerfile`
- `helm`
- `markdown`
- `markdown_inline`
- `yaml`
- `vim`
- `vimdoc`

## LSP Servers

Enabled in config:

- `bashls`
- `lua_ls`
- `pyright`
- `ts_ls`
- `html`
- `cssls`
- `jsonls`
- `dockerls`
- `yamlls`
- `helm_ls`
- `marksman`
- `vimls`

## Notes

- `gitsigns.nvim` shows git signs and current-line blame.
- `lualine` uses Fugitive data for branch and status indicators.
- `colors.lua` removes the background from `Normal` and `NormalFloat`.
- LSP diagnostics treat `vim` as a valid global in `lua_ls`.
