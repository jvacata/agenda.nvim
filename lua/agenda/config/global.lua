local GlobalConfig = {}

GlobalConfig.path = ''
GlobalConfig.tasks_path = ''
GlobalConfig.ns = vim.api.nvim_create_namespace("agenda")

function GlobalConfig:set_paths(path)
    self.path = path
    self.tasks_path = GlobalConfig.path .. '/tasks'
end

function GlobalConfig:init()
    self:set_paths(vim.fn.expand('~/.local/share/agenda.nvim'))
end

return GlobalConfig
