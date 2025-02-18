-- Telescope config

local builtin = require('telescope.builtin')
local previewers = require('telescope.previewers')
local previewers_utils = require('telescope.previewers.utils')

local max_size = 100000
local truncate_large_files = function(filepath, bufnr, opts)
    opts = opts or {}

    filepath = vim.fn.expand(filepath)
    vim.loop.fs_stat(filepath, function(_, stat)
        if not stat then return end
        if stat.size > max_size then
            local cmd = {"head", "-c", max_size, filepath}
            previewers_utils.job_maker(cmd, bufnr, opts)
        else
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
        end
    end)
end

require('telescope').setup {
  defaults = {
    buffer_previewer_maker = truncate_large_files,
  }
}

vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})

-- lsp
vim.keymap.set("n", "<leader>vrr", function() builtin.lsp_references() end, {})
vim.keymap.set("n", "gd", function() builtin.lsp_definitions() end, {})
vim.keymap.set("n", "<leader>vds", function() builtin.lsp_document_symbols() end, {})
vim.keymap.set("n", "<leader>vws", function() builtin.lsp_workspace_symbols() end, {})
