require('jugacu.set')
require('jugacu.remap')
require('jugacu.autocmd')

local augroup = vim.api.nvim_create_augroup
local JugacuGroup = augroup('Jugacu', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({ "BufWritePre" }, {
    group = JugacuGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

local Plug = vim.fn['plug#']

vim.call('plug#begin')

-- Theme
Plug('rose-pine/neovim')

-- Telescope
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.6' })
Plug('nvim-telescope/telescope-fzf-native.nvim',
    {
        ['do'] =
        'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
    })

-- LSP
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('L3MON4D3/LuaSnip')
Plug('VonHeikemen/lsp-zero.nvim', { ['branch'] = 'v3.x' })
Plug('nvimtools/none-ls.nvim')
Plug('nvimtools/none-ls-extras.nvim')

-- DEBUGGING
Plug('jay-babu/mason-nvim-dap.nvim')
Plug('mfussenegger/nvim-dap')
Plug('leoluz/nvim-dap-go')
Plug('nvim-neotest/nvim-nio')
Plug('rcarriga/nvim-dap-ui')

-- Misc
Plug('tpope/vim-fugitive')
Plug('airblade/vim-gitgutter')
Plug('mbbill/undotree')
Plug('theprimeagen/harpoon')

Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('nvim-treesitter/nvim-treesitter-context')

vim.call('plug#end')

vim.cmd.colorscheme('rose-pine')
