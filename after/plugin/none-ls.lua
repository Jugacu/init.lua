local null_ls = require("null-ls")

-- Helper to conditionally register eslint handlers only if eslint is
-- config. If eslint is not configured for a project, it just fails.
local function has_eslint_config(utils)
    local paths_to_check = {
        ".",        -- Root directory
        "frontend", -- `frontend` subdirectory truly this is only used on cheerfy's admin web
    }
    local eslint_files = {
        ".eslintrc",
        ".eslintrc.cjs",
        ".eslintrc.js",
        ".eslintrc.json",
        "eslint.config.cjs",
        "eslint.config.js",
        "eslint.config.mjs",
    }

    -- Check for the ESLint configuration file in both root and `frontend`
    for _, dir in ipairs(paths_to_check) do
        for _, file in ipairs(eslint_files) do
            if utils.root_has_file(dir .. "/" .. file) then
                return true
            end
        end
    end
    return false
end
null_ls.setup({
    sources = {
        require("none-ls.diagnostics.eslint_d").with({ condition = has_eslint_config }), -- requires none-ls-extras.nvim
        require("none-ls.formatting.eslint_d").with({ condition = has_eslint_config }),  -- requires none-ls-extras.nvim
    },
})
