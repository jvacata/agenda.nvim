local M = {}

M.task_list_window = function()
    return {
        relative = 'editor',
        width = math.floor(40),
        height = math.floor(vim.o.lines * 0.8),
        row = math.floor(vim.o.lines * 0.1),
        col = math.floor(vim.o.columns * 0.1),
        style = 'minimal',
        border = 'rounded',
    }
end

M.task_detail_window = function()
    return {
        relative = 'editor',
        width = math.floor(100),
        height = math.floor(vim.o.lines * 0.8),
        row = math.floor(vim.o.lines * 0.1),
        col = math.floor(vim.o.columns * 0.3),
        style = 'minimal',
        border = 'rounded',
    }
end

M.task_edit_window = function()
    return {
        relative = 'editor',
        width = math.floor(40),
        height = math.floor(1),
        row = math.floor(vim.o.lines * 0.45),
        col = math.floor(vim.o.columns * 0.4),
        style = 'minimal',
        border = 'rounded',
    }
end

return M
