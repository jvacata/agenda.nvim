local CalendarView = {}

local window_config = require("agenda.config.window")
local window_util = require("agenda.util.window")
local global_config = require("agenda.config.global")

CalendarView.bufnr = nil
CalendarView.winnr = nil

local month_names = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
}

function CalendarView:init()
    local win_cfg = window_config:calendar_window()
    CalendarView.bufnr, CalendarView.winnr = window_util:get_win("agenda_calendar", win_cfg)
    window_util:clean_buffer(self.bufnr)
end

---Render the calendar view with provided data
---@param view_data {year: number, month: number, day: number, hour: number, minute: number, active_field: "day"|"time", month_data: {first_weekday: number, days_in_month: number}}
function CalendarView:render(view_data)
    if not view_data then
        return
    end

    window_util:hide_cursor()
    vim.api.nvim_set_option_value('modifiable', true, { buf = self.bufnr })

    local lines = self:build_lines(view_data)
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)

    vim.api.nvim_set_option_value('modifiable', false, { buf = self.bufnr })

    self:apply_highlights(view_data, lines)
end

---Build all lines for the calendar display
---@param view_data table
---@return string[]
function CalendarView:build_lines(view_data)
    local lines = {}

    -- Header: month name + year, centered
    local header = month_names[view_data.month] .. " " .. view_data.year
    local pad = math.floor((24 - #header) / 2)
    table.insert(lines, string.rep(" ", pad) .. header)

    -- Weekday header
    table.insert(lines, " Mo Tu We Th Fr Sa Su")

    -- Day grid
    local md = view_data.month_data
    local day_num = 1
    local first_wd = md.first_weekday

    -- Build weeks
    while day_num <= md.days_in_month do
        local row = ""
        for col = 1, 7 do
            if day_num == 1 and col < first_wd then
                row = row .. "   "
            elseif day_num > md.days_in_month then
                row = row .. "   "
            else
                row = row .. string.format("%3d", day_num)
                day_num = day_num + 1
            end
        end
        table.insert(lines, row)
    end

    -- Empty line before time
    table.insert(lines, "")

    -- Time row, centered
    local time_str = string.format("%02d : %02d", view_data.hour, view_data.minute)
    local time_pad = math.floor((24 - #time_str) / 2)
    table.insert(lines, string.rep(" ", time_pad) .. time_str)

    return lines
end

---Apply highlights for selected day and active field
---@param view_data table
---@param lines string[]
function CalendarView:apply_highlights(view_data, lines)
    self:clear_marks()

    local md = view_data.month_data
    local target_day = view_data.day

    -- Find the row and column of the selected day
    local day_num = 1
    local first_wd = md.first_weekday
    local row_offset = 2 -- 0=header, 1=weekday header, 2=first day row

    local found_row, found_col = nil, nil
    while day_num <= md.days_in_month do
        for col = 1, 7 do
            if day_num == 1 and col < first_wd then
                -- skip empty cells
            elseif day_num > md.days_in_month then
                break
            else
                if day_num == target_day then
                    found_row = row_offset
                    found_col = (col - 1) * 3 -- each cell is 3 chars wide
                end
                day_num = day_num + 1
            end
        end
        row_offset = row_offset + 1
    end

    -- Highlight selected day
    if found_row and found_col and found_row < #lines then
        vim.api.nvim_buf_set_extmark(self.bufnr, global_config.ns, found_row, found_col, {
            end_col = found_col + 3,
            hl_group = "Search"
        })
    end

    -- Highlight time row when active_field = "time"
    local time_row = #lines - 1
    if view_data.active_field == "time" and time_row >= 0 then
        local time_line = lines[time_row + 1]
        if time_line then
            vim.api.nvim_buf_set_extmark(self.bufnr, global_config.ns, time_row, 0, {
                end_col = #time_line,
                hl_group = "Search"
            })
        end
    end
end

---Clear all extmarks from buffer
function CalendarView:clear_marks()
    local all = vim.api.nvim_buf_get_extmarks(self.bufnr, global_config.ns, 0, -1, {})
    for _, mark in pairs(all) do
        vim.api.nvim_buf_del_extmark(self.bufnr, global_config.ns, mark[1])
    end
end

function CalendarView:destroy()
    vim.api.nvim_win_close(self.winnr, true)
end

return CalendarView
