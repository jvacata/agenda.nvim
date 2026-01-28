local M = {}

local task_repository = require('agenda.repository.task_repository')

M.update_task = function(task)
    local filepath = vim.fn.expand("~/.local/share/agenda.nvim/tasks/")
    M.ensure_file_path(filepath)
    local file = io.open(filepath .. task.id, "w")
    local json = vim.json.encode(task)
    file:write(json)
    file:close()
end

M.load_tasks = function()
    task_repository.clear()
    local filepath = vim.fn.expand("~/.local/share/agenda.nvim/tasks/")
    for _, file in ipairs(vim.fn.glob(filepath .. "*", 0, 1)) do
        local f = io.open(file, "r")
        local content = f:read("*a")
        local data = vim.json.decode(content)
        f:close()
        task_repository.add(data)
    end
end

M.ensure_dir = function(path)
    os.execute('mkdir -p "' .. path .. '"')
end

M.ensure_file_path = function(filepath)
    local dir = filepath:match("(.*/)")
    if dir then
        M.ensure_dir(dir)
    end
end

return M
