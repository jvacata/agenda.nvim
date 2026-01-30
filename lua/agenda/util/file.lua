local FileUtils = {}

function FileUtils:save_file(path, filename, content)
    FileUtils:ensure_file_path(path .. "/")

    local file = io.open(path .. "/" .. filename, "w")
    print(path)
    file:write(content)
    file:close()
end

function FileUtils:remove_file(path, filename)
    local filepath = path .. "/" .. filename
    os.remove(filepath)
end

function FileUtils:load_file(file)
    local f = io.open(file, "r")
    local content = f:read("*a")
    local data = vim.json.decode(content)
    f:close()
    return data
end

function FileUtils:get_dir_files(dir)
    return vim.fn.glob(dir .. "/*", false, true)
end

function FileUtils:ensure_file_path(filepath)
    print("Ensuring file path for: " .. filepath)
    local dir = filepath:match("(.*/)")
    if dir then
        FileUtils:ensure_dir(dir)
    end
end

function FileUtils:ensure_dir(path)
    print("Ensuring directory: " .. path)
    os.execute('mkdir -p "' .. path .. '"')
end

return FileUtils
