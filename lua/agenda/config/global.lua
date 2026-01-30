local GlobalConfig = {}

GlobalConfig.path = ''
GlobalConfig.tasks_path = ''
GlobalConfig.ns = vim.api.nvim_create_namespace("agenda")
GlobalConfig.orig_cursor_value = ''

function GlobalConfig:set_paths(path)
    self.path = path
    self.tasks_path = GlobalConfig.path .. '/tasks'
end

function GlobalConfig:init()
    self:set_paths(vim.fn.expand('~/.local/share/agenda.nvim'))
    self.orig_cursor_value = vim.api.nvim_get_option_value('guicursor', {})
end

return GlobalConfig
