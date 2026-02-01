local InputController = {}

local input_model = require("agenda.model.entity.input")
local input_view = require("agenda.view.input")
local render_controller = require("agenda.controller.render")

function InputController:init()
end

function InputController:init_view(params)
    input_model:open(params.data, params.callback)
    input_view:init(input_model:get_value())
    self:bind_mapping()
end

function InputController:bind_mapping()
    vim.keymap.set('n', 'q', function() InputController:cancel_edit() end,
        { buffer = input_view.bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() InputController:close_edit() end,
        { buffer = input_view.bufnr, silent = true })
    vim.keymap.set('i', '<CR>', function() vim.cmd("stopinsert") end,
        { buffer = input_view.bufnr, silent = true })
end

---Get view data for rendering
---@return {value: string}
function InputController:get_view_data()
    return {
        value = input_model:get_value()
    }
end

function InputController:cancel_edit()
    local callback = input_model:get_callback()
    input_model:close()
    render_controller:remove_view("input")
    if callback then
        callback()
    end
end

function InputController:close_edit()
    local value = InputController:get_value()
    local callback = input_model:get_callback()
    input_model:close()
    render_controller:remove_view("input")
    if callback then
        callback(value)
    end
end

function InputController:get_value()
    return input_view:get_buffer_value()
end

return InputController
