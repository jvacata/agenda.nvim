local WindowConfig = {}

function WindowConfig:task_list_window()
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

function WindowConfig:task_detail_window()
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

function WindowConfig:task_edit_window()
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

return WindowConfig
