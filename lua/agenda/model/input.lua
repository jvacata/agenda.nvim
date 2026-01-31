---@class InputModel
---@field private _orig_value string
---@field private _value string
---@field private _callback function|nil
---@field private _is_active boolean
local InputModel = {}

InputModel._orig_value = ""
InputModel._value = ""
InputModel._callback = nil
InputModel._is_active = false

---Open input with initial value and callback
---@param value string
---@param callback function
function InputModel:open(value, callback)
    self._orig_value = value or ""
    self._value = value or ""
    self._callback = callback
    self._is_active = true
end

---Close input and reset state
function InputModel:close()
    self._orig_value = ""
    self._value = ""
    self._callback = nil
    self._is_active = false
end

---Get current value
---@return string
function InputModel:get_value()
    return self._value
end

---Set current value
---@param value string
function InputModel:set_value(value)
    self._value = value
end

---Get original value
---@return string
function InputModel:get_orig_value()
    return self._orig_value
end

---Check if input is active
---@return boolean
function InputModel:is_active()
    return self._is_active
end

---Get callback function
---@return function|nil
function InputModel:get_callback()
    return self._callback
end

---Execute callback with value
---@param value string|nil
function InputModel:execute_callback(value)
    if self._callback then
        self._callback(value)
    end
end

return InputModel
