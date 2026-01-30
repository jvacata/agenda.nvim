local WindowUtils = {}

local global_config = require('agenda.config.global')

function WindowUtils:get_win(buf_name, win_cfg)
    local bufnr = WindowUtils:get_or_create_buffer(buf_name)
    vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })

    local winnr = WindowUtils:get_or_create_window(bufnr, win_cfg)

    vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(winnr),
        callback = function()
            self:show_cursor()
        end
    })

    return bufnr, winnr
end

function WindowUtils:get_or_create_window(bufnr, win_cfg)
    local wins = vim.api.nvim_list_wins()
    for _, win_id in pairs(wins) do
        local win_currect_buf_id = vim.api.nvim_win_get_buf(win_id)
        if win_currect_buf_id == bufnr then
            vim.api.nvim_tabpage_set_win(0, win_id)
            return win_id
        end
    end

    return vim.api.nvim_open_win(bufnr, true, win_cfg)
end

function WindowUtils:get_or_create_buffer(buf_name)
    local buf_list = vim.api.nvim_list_bufs()
    local existing_messages_buf = nil
    for _, buf_id in pairs(buf_list) do
        local name = vim.api.nvim_call_function("bufname", { buf_id })
        if name == buf_name then
            existing_messages_buf = buf_id
            break
        end
    end

    if existing_messages_buf then
        return existing_messages_buf
    end

    local new_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(new_bufnr, buf_name)
    return new_bufnr
end

function WindowUtils:clean_buffer(bufnr)
    vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
end

function WindowUtils:hide_cursor()
    vim.api.nvim_set_option_value('guicursor', 'n-v-i:NoCursor', {})
end

function WindowUtils:show_cursor()
    vim.api.nvim_set_option_value('guicursor', global_config.orig_cursor_value, {})
end

return WindowUtils
