local StringUtils = {}

function StringUtils:is_valid_uuid(str)
    return str:match("^[%w%-]+$") ~= nil
end

return StringUtils
