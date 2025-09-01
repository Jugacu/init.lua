local M = {}
local lspconfig_util = require("lspconfig.util")

-- Generic helper function to check for config files in multiple directories
local function has_config(subdirs, config_files)
    local root_dir = vim.fn.getcwd()
    local paths_to_check = { root_dir }

    -- Add subdirectories if provided
    if subdirs then
        for _, subdir in ipairs(subdirs) do
            table.insert(paths_to_check, root_dir .. "/" .. subdir)
        end
    end

    -- Check for config files in all paths
    for _, dir in ipairs(paths_to_check) do
        for _, file in ipairs(config_files) do
            if lspconfig_util.path.exists(dir .. "/" .. file) then
                return true
            end
        end
    end

    return false
end

-- ESLint config checker (maintains your existing logic with frontend subdirectory)
M.has_eslint_config = function()
    return has_config({ "frontend" }, {
        "pnpm-workspace.yaml",
        ".eslintrc",
        ".eslintrc.cjs",
        ".eslintrc.js",
        ".eslintrc.json",
        "eslint.config.cjs",
        "eslint.config.js",
        "eslint.config.mjs",
    })
end

-- Prettier config checker (no subdirectories needed)
M.has_prettier_config = function()
    return has_config(nil, {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.yaml",
        ".prettierrc.yml",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.mjs",
        "prettier.config.js",
        "prettier.config.cjs",
        "prettier.config.mjs",
    })
end

return M
