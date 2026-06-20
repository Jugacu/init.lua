local lsp_zero = require('lsp-zero')
local utils = require("utils")

lsp_zero.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    -- this is handled in telescope now
    -- vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    -- vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    -- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

--- if you want to know more about lsp-zero and mason.nvim
--- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guide/integrate-with-mason-nvim.md
require('mason').setup({
    ensure_installed = { "prettier", "ruff" }
})
require('mason-lspconfig').setup({
    ensure_installed = { "gopls", "lua_ls", "ts_ls", "html", "jsonls", "pyright", "biome" },
    handlers = {
        function(server_name)
            require('lspconfig')[server_name].setup({})
        end,
        ts_ls = function()
            require('lspconfig').ts_ls.setup({
                filetypes = {
                    "javascript",
                    "javascriptreact",
                    "javascript.jsx",
                    "typescript",
                    "typescriptreact",
                    "typescript.tsx",
                    "vue",
                    "clangd",
                },
                on_attach = function(client, bufnr)
                    -- Cede formatting to whichever external tool owns the project so we
                    -- don't double-format: eslint (via none-ls) or Biome (its own LSP).
                    local fmt_owned_by_other = utils.has_eslint_config(client.config.root_dir)
                        or utils.has_biome_config(client.config.root_dir)
                    client.server_capabilities.documentFormattingProvider = not fmt_owned_by_other
                end,
            })
        end,
        -- Biome's native LSP: diagnostics, formatting, and organize-imports code
        -- actions, matching `biome check`. It auto-roots on biome.json, so it only
        -- attaches inside projects that adopt Biome. The `css` filetype lets it
        -- format/lint CSS Modules through the same client.
        biome = function()
            require('lspconfig').biome.setup({
                filetypes = {
                    "javascript",
                    "javascriptreact",
                    "typescript",
                    "typescriptreact",
                    "json",
                    "jsonc",
                    "css",
                },
                -- Prefer the project-local Biome (pinned in node_modules) over mason's, so
                -- the editor's lint/format always matches the version the CLI and CI use.
                -- A mason binary on a different version can reject a newer biome.json schema
                -- and then silently emit no diagnostics. Falls back to mason/PATH when there
                -- is no local install.
                on_new_config = function(new_config, root_dir)
                    local uv = vim.uv or vim.loop
                    local local_bin = root_dir .. "/node_modules/.bin/biome"
                    if uv.fs_stat(local_bin) then
                        new_config.cmd = { local_bin, "lsp-proxy" }
                    end
                end,
            })
        end,
        html = function()
            require('lspconfig').html.setup({
                settings = {
                    html = {
                        format = {
                            templating = true,
                            wrapLineLength = 120,
                            wrapAttributes = 'preserve-aligned',
                            indentInnerHtml = true,
                        },
                        hover = {
                            documentation = true,
                            references = true,
                        },
                    }
                }
            })
        end,
        lua_ls = function()
            -- (Optional) configure lua language server
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
        end,
        gopls = function()
            require('lspconfig').gopls.setup({
                settings = {
                    gopls = {
                        directoryFilters = {
                            "-bazel-bin",
                            "-bazel-out",
                            "-bazel-testlogs",
                            "-bazel-mypkg",
                        },
                    },
                },
            })
        end,
        pyright = function()
            local lspconfig_util = require('lspconfig.util')
            require('lspconfig').pyright.setup({
                root_dir = lspconfig_util.root_pattern(
                    'pyrightconfig.json', 'pyproject.toml', 'setup.py', 'setup.cfg',
                    'requirements.txt', 'Pipfile', '.git'
                ),
                on_new_config = function(new_config, root_dir)
                    local pyver  = utils.detect_python_version(root_dir)
                    local py_bin = utils.get_project_python(root_dir)
                    new_config.settings = new_config.settings or {}
                    new_config.settings.python = new_config.settings.python or {}
                    new_config.settings.python.pythonVersion = (pyver == 2) and "2.7" or nil
                    if py_bin then
                        new_config.settings.python.pythonPath = py_bin
                    end
                end,
            })
        end,
    }
})

---
-- Autocompletion config
---
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ['<Tab>'] = nil,
        ['<S-Tab>'] = nil,
    }),
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'buffer' },
    }),
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
})
