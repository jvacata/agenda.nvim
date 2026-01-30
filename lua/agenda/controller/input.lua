local InputController = {}

local input_model = require("agenda.model.input")
local input_view = require("agenda.view.input")
local render_controller = require("agenda.controller.render")

InputController.callback = nil

function InputController:init()
end

function InputController:init_view(params)
    input_view:init()
    self:bind_mapping()

    self.callback = params.callback
    input_model.orig_value = params.data
    input_model.input = params.data
end

function InputController:bind_mapping()
    vim.keymap.set('n', 'q', function() InputController:cancel_edit() end,
        { buffer = input_view.bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() InputController:close_edit() end,
        { buffer = input_view.bufnr, silent = true })
    vim.keymap.set('i', '<CR>', function() vim.cmd("stopinsert") end,
        { buffer = input_view.bufnr, silent = true })
end

function InputController:cancel_edit()
    render_controller:remove_view("input")
    self.callback()
end

function InputController:close_edit()
    local value = InputController:get_value()
    render_controller:remove_view("input")
    self.callback(value)
end

function InputController:get_value()
    return vim.api.nvim_buf_get_lines(input_view.bufnr, 0, 1, false)[1]
end

return InputController
