local FileUtils = {}

function FileUtils:save_file(path, filename, content)
    FileUtils:ensure_file_path(path .. "/")

    local filepath = path .. "/" .. filename
    local file, err = io.open(filepath, "w")
    if not file then
        error("Failed to open file for writing: " .. filepath .. " - " .. tostring(err))
    end

    file:write(content)
    file:close()
end

function FileUtils:remove_file(path, filename)
    local filepath = path .. "/" .. filename
    os.remove(filepath)
end

function FileUtils:load_file(file)
    local f, err = io.open(file, "r")
    if not f then
        error("Failed to open file for reading: " .. vim.inspect(file) .. " - " .. tostring(err))
    end
    local content = f:read("*a")
    f:close()

    local ok, data = pcall(vim.json.decode, content)
    if not ok then
        error("Failed to decode JSON from file: " .. vim.inspect(file) .. " - " .. tostring(data))
    end
    return data
end

function FileUtils:get_dir_files(dir)
    return vim.fn.glob(dir .. "/*", false, true)
end

function FileUtils:ensure_file_path(filepath)
    local dir = filepath:match("(.*/)")
    if dir then
        FileUtils:ensure_dir(dir)
    end
end

function FileUtils:ensure_dir(path)
    vim.fn.mkdir(path, "p")
end

return FileUtils
