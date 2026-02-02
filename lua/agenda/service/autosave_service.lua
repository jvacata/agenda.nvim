local AutosaveService = {}

local global_config = require('agenda.config.global')

---Check if workspace is a git repository
---@return boolean
local function is_git_repo()
    local cmd = 'git -C ' ..
        vim.fn.shellescape(global_config.user_config.workspace_path) .. ' rev-parse --is-inside-work-tree 2>/dev/null'
    local result = vim.fn.system(cmd)
    return vim.v.shell_error == 0 and vim.trim(result) == 'true'
end

---Commit and push changes to git
function AutosaveService:autosave()
    if not is_git_repo() then
        error("Workspace is not a git repository")
    end

    -- Stage all changes
    local stage_cmd = 'git -C ' .. global_config.user_config.workspace_path .. ' add -A'
    vim.fn.system(stage_cmd)
    if vim.v.shell_error ~= 0 then
        error("Failed to stage changes")
    end

    -- Commit with timestamp
    local commit_msg = 'autosave: ' .. os.date('%Y-%m-%d %H:%M:%S')
    local commit_cmd = 'git -C ' ..
        global_config.user_config.workspace_path .. ' commit -m ' .. vim.fn.shellescape(commit_msg)
    print(commit_cmd)
    vim.fn.system(commit_cmd)
    if vim.v.shell_error ~= 0 then
        error("Failed to commit changes")
    end

    -- Push to remote
    vim.fn.system('git -C ' .. global_config.user_config.workspace_path .. ' push')
    if vim.v.shell_error ~= 0 then
        error("Failed to push changes")
    end
end

return AutosaveService
