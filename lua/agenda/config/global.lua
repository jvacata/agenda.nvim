local M = {}

M.path = ''
M.tasks_path = ''
M.ns = vim.api.nvim_create_namespace("agenda")

M.set_paths = function(path)
    M.path = path
    M.tasks_path = M.path .. '/tasks'
end

M.set_paths(vim.fn.expand('~/.local/share/agenda.nvim'))

return M
