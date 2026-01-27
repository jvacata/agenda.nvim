local M = {}

M.create_or_find_main_window = function()
    local bufnr = M.get_or_create_buffer()
    return vim.api.nvim_open_win(bufnr, true, {
        relative = 'editor',
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        row = math.floor(vim.o.lines * 0.1),
        col = math.floor(vim.o.columns * 0.1),
        style = 'minimal',
        border = 'rounded',
    })
end

M.get_or_create_buffer = function()
    local buf_list = vim.api.nvim_list_bufs()
    local existing_messages_buf = nil
    for _, buf_id in pairs(buf_list) do
        local name = vim.api.nvim_call_function("bufname", { buf_id })
        if name == "Agenda" then
            existing_messages_buf = buf_id
            break
        end
    end
    return existing_messages_buf or vim.api.nvim_create_buf(false, true)
end


return M
