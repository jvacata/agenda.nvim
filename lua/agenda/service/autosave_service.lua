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
    if not global_config.user_config.autosave then
        return
    end

    if global_config.user_config.autosave_type ~= 'git' then
        error("Unsupported autosave type: " ..
        global_config.user_config.autosave_type .. ". Only 'git' is supported for now.")
    end

    if not is_git_repo() then
        error("Workspace is not a git repository")
    end

    local workspace = global_config.user_config.workspace_path

    -- Stage all changes
    local stage_cmd = 'git -C ' .. workspace .. ' add -A'
    vim.fn.system(stage_cmd)
    if vim.v.shell_error ~= 0 then
        error("Failed to stage changes")
    end

    -- Check if there are staged changes to commit
    local diff_cmd = 'git -C ' .. workspace .. ' diff --cached --quiet'
    vim.fn.system(diff_cmd)
    if vim.v.shell_error == 0 then
        -- No changes to commit
        return
    end

    -- Commit with timestamp
    local commit_msg = 'autosave: ' .. os.date('%Y-%m-%d %H:%M:%S')
    local commit_cmd = 'git -C ' .. workspace .. ' commit -m ' .. vim.fn.shellescape(commit_msg)
    vim.fn.system(commit_cmd)
    if vim.v.shell_error ~= 0 then
        error("Failed to commit changes")
    end

    -- Push to remote asynchronously
    vim.fn.jobstart('git -C ' .. workspace .. ' push', {
        on_exit = function(_, exit_code)
            if exit_code ~= 0 then
                vim.schedule(function()
                    vim.notify("Autosave: Failed to push changes", vim.log.levels.WARN)
                end)
            end
        end
    })
end

return AutosaveService
