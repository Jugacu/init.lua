local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local function augroup_fn(name, fnc)
    fnc(augroup(name, { clear = true }))
end

-- credits to ibhagwan
augroup_fn("ibhagwan/ToggleSearchHL", function(g)
    autocmd("InsertEnter", {
        group = g,
        callback = function()
            vim.schedule(function() vim.cmd("nohlsearch") end)
        end
    })
    autocmd("CursorMoved", {
        group = g,
        callback = function()
            -- No bloat lua adpatation of: https://github.com/romainl/vim-cool
            local view, rpos = vim.fn.winsaveview(), vim.fn.getpos(".")
            -- Move the cursor to a position where (whereas in active search) pressing `n`
            -- brings us to the original cursor position, in a forward search / that means
            -- one column before the match, in a backward search ? we move one col forward
            vim.cmd(string.format("silent! keepjumps go%s",
                (vim.fn.line2byte(view.lnum) + view.col + 1 - (vim.v.searchforward == 1 and 2 or 0))))
            -- Attempt to goto next match, if we're in an active search cursor position
            -- should be equal to original cursor position
            local ok, _ = pcall(vim.cmd, "silent! keepjumps norm! n")
            local insearch = ok and (function()
                local npos = vim.fn.getpos(".")
                return npos[2] == rpos[2] and npos[3] == rpos[3]
            end)()
            -- restore original view and position
            vim.fn.winrestview(view)
            if not insearch then
                vim.schedule(function() vim.cmd("nohlsearch") end)
            end
        end
    })
end)


local JugacuGroup = augroup('Jugacu', {})

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
