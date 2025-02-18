local null_ls = require("null-ls")
local utils = require("utils")

-- Set environment variables for eslint_d
vim.env.ESLINT_D_IDLE = "10"                      -- Terminate after 10 seconds of inactivity
vim.env.ESLINT_D_PPID = tostring(vim.fn.getpid()) -- Tie eslint_d to Neovim's lifecycle

-- Helper to conditionally register eslint handlers only if eslint is
-- config. If eslint is not configured for a project, it just fails.
local function has_eslint_config()
    return utils.has_eslint_config(vim.fn.getcwd())
end

null_ls.setup({
    sources = {
        require("none-ls.diagnostics.eslint_d").with({ condition = has_eslint_config }), -- requires none-ls-extras.nvim
        require("none-ls.formatting.eslint_d").with({ condition = has_eslint_config }),  -- requires none-ls-extras.nvim
    },
})
