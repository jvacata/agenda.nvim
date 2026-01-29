local InputController = {}

local input_view = require("agenda.view.input")

InputController.callback = nil

function InputController:initialize(callback)
    InputController.callback = callback

    InputController:set_edit_window_mapping()
end

function InputController:set_edit_window_mapping(bufnr, winnr, list_bufnr, detail_bufnr)
    vim.keymap.set('n', 'q', function() InputController:cancel_edit() end,
        { buffer = true, silent = true })
    vim.keymap.set('n', '<CR>', function() InputController:close_edit() end,
        { buffer = true, silent = true })
end

function InputController:cancel_edit()
    input_view.destroy()
    InputController:callback()
end

function InputController:close_edit()
    local value = InputController:get_value()
    input_view.destroy()
    InputController:callback(value)
end

function InputController:get_value()
    return vim.api.nvim_buf_get_lines(input_view.bufnr, 0, 1, false)[1]
end

return InputController
