local CalendarController = {}

local calendar_model = require("agenda.model.entity.calendar")
local calendar_view = require("agenda.view.calendar")
local render_controller = require("agenda.controller.render")

function CalendarController:init()
end

---Initialize the calendar view
---@param params {data: number|nil, callback: function}
function CalendarController:init_view(params)
    calendar_model:open(params.data, params.callback)
    calendar_view:init()
    self:bind_mapping()
    self:render()
end

function CalendarController:bind_mapping()
    local bufnr = calendar_view.bufnr

    vim.keymap.set('n', 'h', function() CalendarController:handle_left() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'l', function() CalendarController:handle_right() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'j', function() CalendarController:handle_down() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'k', function() CalendarController:handle_up() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'H', function() CalendarController:handle_prev_month() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'L', function() CalendarController:handle_next_month() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', '<Tab>', function() CalendarController:handle_toggle() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', '<CR>', function() CalendarController:confirm() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'q', function() CalendarController:cancel() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'x', function() CalendarController:clear() end,
        { buffer = bufnr, silent = true })
    vim.keymap.set('n', 'i', '<Nop>', { buffer = bufnr, silent = true })
end

function CalendarController:handle_left()
    if calendar_model:get_active_field() == "day" then
        calendar_model:prev_day()
    else
        calendar_model:decrement_hour()
    end
    self:render()
end

function CalendarController:handle_right()
    if calendar_model:get_active_field() == "day" then
        calendar_model:next_day()
    else
        calendar_model:increment_hour()
    end
    self:render()
end

function CalendarController:handle_down()
    if calendar_model:get_active_field() == "day" then
        calendar_model:next_week()
    else
        calendar_model:decrement_minute()
    end
    self:render()
end

function CalendarController:handle_up()
    if calendar_model:get_active_field() == "day" then
        calendar_model:prev_week()
    else
        calendar_model:increment_minute()
    end
    self:render()
end

function CalendarController:handle_prev_month()
    calendar_model:prev_month()
    self:render()
end

function CalendarController:handle_next_month()
    calendar_model:next_month()
    self:render()
end

function CalendarController:handle_toggle()
    calendar_model:toggle_field()
    self:render()
end

function CalendarController:confirm()
    local timestamp = calendar_model:get_timestamp()
    local callback = calendar_model:get_callback()
    calendar_model:close()
    render_controller:remove_view("calendar")
    if callback then
        callback(timestamp)
    end
end

function CalendarController:cancel()
    local callback = calendar_model:get_callback()
    calendar_model:close()
    render_controller:remove_view("calendar")
    if callback then
        callback(nil)
    end
end

function CalendarController:clear()
    local callback = calendar_model:get_callback()
    calendar_model:close()
    render_controller:remove_view("calendar")
    if callback then
        callback("clear")
    end
end

---Get view data for rendering
---@return table
function CalendarController:get_view_data()
    return {
        year = calendar_model:get_year(),
        month = calendar_model:get_month(),
        day = calendar_model:get_day(),
        hour = calendar_model:get_hour(),
        minute = calendar_model:get_minute(),
        active_field = calendar_model:get_active_field(),
        month_data = calendar_model:get_month_data()
    }
end

---Render the calendar
function CalendarController:render()
    calendar_view:render(self:get_view_data())
end

return CalendarController
