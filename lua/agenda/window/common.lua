local M = {}

M.get_win = function()
    local bufnr = M.get_or_create_buffer()
    vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })

    local winnr = M.get_or_create_window(bufnr)

    vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(winnr),
        callback = function()
            vim.api.nvim_set_option_value('guicursor',
                'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor', {})
        end
    })

    return bufnr, winnr
end

M.get_or_create_window = function(bufnr)
    local wins = vim.api.nvim_list_wins()
    for _, win_id in pairs(wins) do
        local win_currect_buf_id = vim.api.nvim_win_get_buf(win_id)
        if win_currect_buf_id == bufnr then
            vim.api.nvim_tabpage_set_win(0, win_id)
            return bufnr, win_id
        end
    end

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

    if existing_messages_buf then
        return existing_messages_buf
    end

    local new_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(new_bufnr, "Agenda")
    return new_bufnr
end

M.clean_buffer = function(bufnr)
    vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
end

return M
