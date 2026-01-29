local M = {}

M.save_file = function(path, filename, content)
    M.ensure_file_path(path)

    local file = io.open(path .. "/" .. filename, "w")
    file:write(content)
    file:close()
end

M.remove_file = function(path, filename)
    local filepath = path .. "/" .. filename
    os.remove(filepath)
end

M.load_file = function(file)
    local f = io.open(file, "r")
    local content = f:read("*a")
    local data = vim.json.decode(content)
    f:close()
    return data
end

M.get_dir_files = function(dir)
    return vim.fn.glob(dir .. "/*", false, true)
end

M.ensure_file_path = function(filepath)
    local dir = filepath:match("(.*/)")
    if dir then
        M.ensure_dir(dir)
    end
end

M.ensure_dir = function(path)
    os.execute('mkdir -p "' .. path .. '"')
end

return M
