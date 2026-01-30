local GlobalConfig = {}

GlobalConfig.user_config = {
    workspace_path = vim.fn.expand('~/.local/share/agenda.nvim'),
}

GlobalConfig.workspace_task_path = ''
GlobalConfig.ns = vim.api.nvim_create_namespace("agenda")
GlobalConfig.orig_cursor_value = ''

function GlobalConfig:init(user_config)
    if type(user_config) ~= 'table' then
        user_config = {}
    end

    self.user_config = vim.tbl_extend('force', self.user_config, user_config)

    self.workspace_path = vim.fn.expand(self.workspace_path)
    self.workspace_task_path = self.user_config.workspace_path .. '/tasks'
    self.orig_cursor_value = vim.api.nvim_get_option_value('guicursor', {})
end

return GlobalConfig
