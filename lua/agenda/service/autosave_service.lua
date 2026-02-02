local AutosaveService = {}

local global_config = require('agenda.config.global')

---Check if workspace is a git repository
---@return boolean
local function is_git_repo()
    local result = vim.fn.system('git -C ' .. vim.fn.shellescape(global_config.workspace_path) .. ' rev-parse --is-inside-work-tree 2>/dev/null')
    return vim.v.shell_error == 0 and vim.trim(result) == 'true'
end

---Commit and push changes to git
function AutosaveService:autosave()
    if not is_git_repo() then
        error("Workspace is not a git repository")
    end

    local workspace = vim.fn.shellescape(global_config.workspace_path)

    -- Stage all changes
    vim.fn.system('git -C ' .. workspace .. ' add -A')
    if vim.v.shell_error ~= 0 then
        error("Failed to stage changes")
    end

    -- Commit with timestamp
    local commit_msg = 'autosave: ' .. os.date('%Y-%m-%d %H:%M:%S')
    vim.fn.system('git -C ' .. workspace .. ' commit -m ' .. vim.fn.shellescape(commit_msg))
    if vim.v.shell_error ~= 0 then
        error("Failed to commit changes")
    end

    -- Push to remote
    vim.fn.system('git -C ' .. workspace .. ' push')
    if vim.v.shell_error ~= 0 then
        error("Failed to push changes")
    end
end

return AutosaveService
