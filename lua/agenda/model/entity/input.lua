---@class InputModel
---@field private _orig_value string
---@field private _value string
---@field private _callback function|nil
---@field private _is_active boolean
---@field private _mode "edit"|"select"|"multiline"
---@field private _options string[]
---@field private _selected_index number
local InputModel = {}

InputModel._orig_value = ""
InputModel._value = ""
InputModel._callback = nil
InputModel._is_active = false
InputModel._mode = "edit"
InputModel._options = {}
InputModel._selected_index = 1

---Open input with initial value and callback
---@param value string|string[] For edit mode: initial string. For select mode: list of options. For multiline: string with newlines.
---@param callback function
---@param mode? "edit"|"select"|"multiline" Defaults to "edit"
function InputModel:open(value, callback, mode)
    self._mode = mode or "edit"
    self._callback = callback
    self._is_active = true

    if self._mode == "select" then
        self._options = value or {}
        self._selected_index = 1
        self._value = self._options[1] or ""
        self._orig_value = self._value
    else
        self._orig_value = value or ""
        self._value = value or ""
        self._options = {}
        self._selected_index = 1
    end
end

---Close input and reset state
function InputModel:close()
    self._orig_value = ""
    self._value = ""
    self._callback = nil
    self._is_active = false
    self._mode = "edit"
    self._options = {}
    self._selected_index = 1
end

---Get current value
---@return string
function InputModel:get_value()
    return self._value
end

---Get callback function
---@return function|nil
function InputModel:get_callback()
    return self._callback
end

---Get current mode
---@return "edit"|"select"|"multiline"
function InputModel:get_mode()
    return self._mode
end

---Get options list (for select mode)
---@return string[]
function InputModel:get_options()
    return self._options
end

---Get selected index (for select mode)
---@return number
function InputModel:get_selected_index()
    return self._selected_index
end

---Move selection to next item
function InputModel:select_next()
    if self._selected_index < #self._options then
        self._selected_index = self._selected_index + 1
        self._value = self._options[self._selected_index]
    end
end

---Move selection to previous item
function InputModel:select_prev()
    if self._selected_index > 1 then
        self._selected_index = self._selected_index - 1
        self._value = self._options[self._selected_index]
    end
end

return InputModel
