local StringUtils = {}

function StringUtils:is_valid_id(str)
    return str:match("^[%w%-]+$") ~= nil
end

return StringUtils
