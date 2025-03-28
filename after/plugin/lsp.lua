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
require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = { "gopls", "lua_ls", "ts_ls", "html", "jsonls" },
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
                },
                on_attach = function(client, bufnr)
                    local eslint_active = utils.has_eslint_config(client.config.root_dir)
                    client.server_capabilities.documentFormattingProvider = not eslint_active
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
        end
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
})
