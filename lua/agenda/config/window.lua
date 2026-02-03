local WindowConfig = {}

function WindowConfig:task_list_window()
    return {
        relative = 'editor',
        width = math.floor(40),
        height = math.floor(vim.o.lines * 0.6),
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
        height = math.floor(vim.o.lines * 0.6),
        row = math.floor(vim.o.lines * 0.1),
        col = math.floor(vim.o.columns * 0.3),
        style = 'minimal',
        border = 'rounded',
    }
end

---@param height? number Window height (default 1)
function WindowConfig:task_edit_window(height)
    height = height or 1
    return {
        relative = 'editor',
        width = math.floor(40),
        height = height,
        row = math.floor(vim.o.lines * 0.45),
        col = math.floor(vim.o.columns * 0.4),
        style = 'minimal',
        border = 'rounded',
    }
end

function WindowConfig:kanban_window()
    return {
        relative = 'editor',
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.6),
        row = math.floor(vim.o.lines * 0.1),
        col = math.floor(vim.o.columns * 0.1),
        style = 'minimal',
        border = 'rounded',
    }
end

function WindowConfig:status_bar_window()
    return {
        relative = 'editor',
        width = math.floor(vim.o.columns * 0.8),
        height = 1,
        row = math.floor(vim.o.lines * 0.7) + 2,
        col = math.floor(vim.o.columns * 0.1),
        style = 'minimal',
        border = 'rounded',
        focusable = false,
    }
end

return WindowConfig
