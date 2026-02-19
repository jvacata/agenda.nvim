---@class CalendarModel
---@field private _year number
---@field private _month number
---@field private _day number
---@field private _hour number
---@field private _minute number
---@field private _active_field "day"|"time"
---@field private _callback function|nil
---@field private _is_active boolean
local CalendarModel = {}

CalendarModel._year = 0
CalendarModel._month = 0
CalendarModel._day = 0
CalendarModel._hour = 0
CalendarModel._minute = 0
CalendarModel._active_field = "day"
CalendarModel._callback = nil
CalendarModel._is_active = false

---Open calendar from an existing timestamp or default to now
---@param timestamp number|nil
---@param callback function
function CalendarModel:open(timestamp, callback)
    local t = os.date("*t", timestamp or os.time())
    self._year = t.year
    self._month = t.month
    self._day = t.day
    self._hour = t.hour
    self._minute = t.min
    self._active_field = "day"
    self._callback = callback
    self._is_active = true
end

---Close calendar and reset state
function CalendarModel:close()
    self._year = 0
    self._month = 0
    self._day = 0
    self._hour = 0
    self._minute = 0
    self._active_field = "day"
    self._callback = nil
    self._is_active = false
end

---Get number of days in a given month/year
---@param year number
---@param month number
---@return number
function CalendarModel:days_in_month(year, month)
    -- day 0 of next month = last day of current month
    return os.date("*t", os.time({ year = year, month = month + 1, day = 0 })).day
end

---Clamp day to valid range for current month
function CalendarModel:clamp_day()
    local max_day = self:days_in_month(self._year, self._month)
    if self._day > max_day then
        self._day = max_day
    end
    if self._day < 1 then
        self._day = 1
    end
end

---Navigate to next day
function CalendarModel:next_day()
    local max_day = self:days_in_month(self._year, self._month)
    if self._day < max_day then
        self._day = self._day + 1
    end
end

---Navigate to previous day
function CalendarModel:prev_day()
    if self._day > 1 then
        self._day = self._day - 1
    end
end

---Navigate to next week (same day, +7)
function CalendarModel:next_week()
    local max_day = self:days_in_month(self._year, self._month)
    if self._day + 7 <= max_day then
        self._day = self._day + 7
    end
end

---Navigate to previous week (same day, -7)
function CalendarModel:prev_week()
    if self._day - 7 >= 1 then
        self._day = self._day - 7
    end
end

---Navigate to next month
function CalendarModel:next_month()
    if self._month == 12 then
        self._month = 1
        self._year = self._year + 1
    else
        self._month = self._month + 1
    end
    self:clamp_day()
end

---Navigate to previous month
function CalendarModel:prev_month()
    if self._month == 1 then
        self._month = 12
        self._year = self._year - 1
    else
        self._month = self._month - 1
    end
    self:clamp_day()
end

---Navigate to next year
function CalendarModel:next_year()
    self._year = self._year + 1
    self:clamp_day()
end

---Navigate to previous year
function CalendarModel:prev_year()
    self._year = self._year - 1
    self:clamp_day()
end

---Increment hour
function CalendarModel:increment_hour()
    self._hour = (self._hour + 1) % 24
end

---Decrement hour
function CalendarModel:decrement_hour()
    self._hour = (self._hour - 1) % 24
end

---Increment minute by 5
function CalendarModel:increment_minute()
    self._minute = (self._minute + 5) % 60
end

---Decrement minute by 5
function CalendarModel:decrement_minute()
    self._minute = (self._minute - 5) % 60
end

---Toggle between "day" and "time" active field
function CalendarModel:toggle_field()
    if self._active_field == "day" then
        self._active_field = "time"
    else
        self._active_field = "day"
    end
end

---Build unix timestamp from current selections
---@return number
function CalendarModel:get_timestamp()
    return os.time({
        year = self._year,
        month = self._month,
        day = self._day,
        hour = self._hour,
        min = self._minute,
        sec = 0
    })
end

---Get metadata for rendering the month grid
---@return {first_weekday: number, days_in_month: number}
function CalendarModel:get_month_data()
    -- wday: 1=Sunday, 2=Monday, ... 7=Saturday
    -- Convert to Monday-based: Mo=1, Tu=2, ..., Su=7
    local first_of_month = os.time({ year = self._year, month = self._month, day = 1 })
    local wday = os.date("*t", first_of_month).wday
    local monday_based = (wday - 2) % 7 + 1  -- Mo=1, Tu=2, ..., Su=7

    return {
        first_weekday = monday_based,
        days_in_month = self:days_in_month(self._year, self._month)
    }
end

---@return function|nil
function CalendarModel:get_callback()
    return self._callback
end

---@return number
function CalendarModel:get_year()
    return self._year
end

---@return number
function CalendarModel:get_month()
    return self._month
end

---@return number
function CalendarModel:get_day()
    return self._day
end

---@return number
function CalendarModel:get_hour()
    return self._hour
end

---@return number
function CalendarModel:get_minute()
    return self._minute
end

---@return "day"|"time"
function CalendarModel:get_active_field()
    return self._active_field
end

---@return boolean
function CalendarModel:is_active()
    return self._is_active
end

return CalendarModel
