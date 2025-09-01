local null_ls = require("null-ls")
local utils = require("utils")

-- Set environment variables for eslint_d
vim.env.ESLINT_D_IDLE = "10"                      -- Terminate after 10 seconds of inactivity
vim.env.ESLINT_D_PPID = tostring(vim.fn.getpid()) -- Tie eslint_d to Neovim's lifecycle

null_ls.setup({
    sources = {
        require("none-ls.diagnostics.eslint_d").with({ condition = utils.has_eslint_config }), -- requires none-ls-extras.nvim
        require("none-ls.formatting.eslint_d").with({ condition = utils.has_eslint_config }),  -- requires none-ls-extras.nvim
        null_ls.builtins.formatting.prettier.with({
            condition = utils.has_prettier_config
        }),
    },
})
