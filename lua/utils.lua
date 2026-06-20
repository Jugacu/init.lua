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

-- Biome config checker. Biome is a single binary that both lints and formats;
-- its presence means it (via its LSP) owns formatting for the project. Includes the
-- `ui` subdir so it resolves from the wirefinder repo root too.
M.has_biome_config = function()
    return has_config({ "frontend", "ui" }, {
        "biome.json",
        "biome.jsonc",
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

M.get_project_python = function(root_dir)
    if not root_dir then return nil end
    for _, venv in ipairs({ ".venv", "venv", "env" }) do
        local p = root_dir .. "/" .. venv .. "/bin/python"
        if vim.loop.fs_stat(p) then return p end
    end
    return nil
end

M.detect_python_version = function(root_dir)
    if not root_dir then return 3 end
    if #vim.fn.glob(root_dir .. "/{.venv,venv,env}/lib/python2.*", false, true) > 0 then
        return 2
    end
    local pv = root_dir .. "/.python-version"
    if lspconfig_util.path.exists(pv) then
        local f = io.open(pv, "r")
        if f then
            local line = f:read("*l") or ""
            f:close()
            if line:match("^2%.") then return 2 end
        end
    end
    if lspconfig_util.path.exists(root_dir .. "/.py2-project") then return 2 end
    return 3
end

M.has_ruff_config = function()
    return has_config(nil, { "pyproject.toml", "ruff.toml", ".ruff.toml" })
end

return M
