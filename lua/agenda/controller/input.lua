local InputController = {}

local input_model = require("agenda.model.entity.input")
local input_view = require("agenda.view.input")
local render_controller = require("agenda.controller.render")

function InputController:init()
end

---Initialize the input view
---@param params {data: string|string[], callback: function, mode?: "edit"|"select"|"multiline"}
function InputController:init_view(params)
    local mode = params.mode or "edit"
    input_model:open(params.data, params.callback, mode)

    if mode == "select" then
        input_view:init(input_model:get_options(), mode)
    else
        input_view:init(input_model:get_value(), mode)
    end

    self:bind_mapping()
    self:render()
end

function InputController:bind_mapping()
    vim.keymap.set('n', 'q', function() InputController:cancel_edit() end,
        { buffer = input_view.bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() InputController:close_edit() end,
        { buffer = input_view.bufnr, silent = true })

    if input_model:get_mode() == "select" then
        vim.keymap.set('n', 'j', function() InputController:select_next() end,
            { buffer = input_view.bufnr, silent = true })
        vim.keymap.set('n', 'k', function() InputController:select_prev() end,
            { buffer = input_view.bufnr, silent = true })
    elseif input_model:get_mode() == "edit" then
        vim.keymap.set('i', '<CR>', function() vim.cmd("stopinsert") end,
            { buffer = input_view.bufnr, silent = true })
    end
    -- multiline mode: insert mode <CR> adds newlines normally, normal mode <CR> saves
end

---Get view data for rendering
---@return {value: string, selected_index: number}
function InputController:get_view_data()
    return {
        value = input_model:get_value(),
        selected_index = input_model:get_selected_index()
    }
end

---Render the input view
function InputController:render()
    input_view:render(self:get_view_data())
end

---Move selection to next item (select mode)
function InputController:select_next()
    input_model:select_next()
    self:render()
end

---Move selection to previous item (select mode)
function InputController:select_prev()
    input_model:select_prev()
    self:render()
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
    if input_model:get_mode() == "select" then
        return input_model:get_value()
    end
    return input_view:get_buffer_value()
end

return InputController
