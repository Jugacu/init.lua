local M = {}

local lspconfig_util = require("lspconfig.util")

-- Helper to conditionally register eslint handlers only if eslint is
-- config. If eslint is not configured for a project, it just fails.
M.has_eslint_config = function (root_dir)
    local paths_to_check = {
        root_dir,                -- Root directory
        root_dir .. "/frontend", -- `frontend` subdirectory truly this is only used on cheerfy's admin web
    }
    local eslint_files = {
        "pnpm-workspace.yaml",
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
            if lspconfig_util.path.exists(dir .. "/" .. file) then
                return true
            end
        end
    end
    return false
end

return M

