local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')
local reminder_service = require('agenda.service.reminder_service')
local reminder_view = require('agenda.view.reminder')
local Task = require('agenda.model.entity.task')
local task_service = require('agenda.service.task_service')
local stub = require("luassert.stub")

global_config:init({
    reminder = {
        enabled = true,
        check_interval = 10,
        remind_interval = 5,
        popup_duration = 10,
    }
})

describe('Reminder service', function()
    local show_stub

    before_each(function()
        file_utils:remove_files_from_folder(global_config.workspace_task_path)
        reminder_service:reset()
        show_stub = stub(reminder_view, 'show')
    end)

    after_each(function()
        if show_stub then
            show_stub:revert()
            show_stub = nil
        end
    end)

    it('does not remind for tasks without due_at', function()
        local task = Task.create("No due date")
        task_service:save_task(task)

        reminder_service:check_overdue_tasks()

        assert.stub(show_stub).was_not_called()
    end)

    it('does not remind for done tasks', function()
        local task = Task.create("Done task", "done")
        task.due_at = os.time() - 600
        task_service:save_task(task)

        reminder_service:check_overdue_tasks()

        assert.stub(show_stub).was_not_called()
    end)

    it('does not remind when task is not overdue enough', function()
        local task = Task.create("Almost overdue")
        -- Only 1 minute overdue, but remind_interval is 5 minutes
        task.due_at = os.time() - 60
        task_service:save_task(task)

        reminder_service:check_overdue_tasks()

        assert.stub(show_stub).was_not_called()
    end)

    it('reminds for properly overdue todo task', function()
        local task = Task.create("Overdue task")
        -- 10 minutes overdue, remind_interval is 5 minutes
        task.due_at = os.time() - 600
        task_service:save_task(task)

        reminder_service:check_overdue_tasks()

        assert.stub(show_stub).was_called(1)
        local args = show_stub.calls[1].refs
        assert.are.equal(1, #args[2])
        assert.are.equal("Overdue task", args[2][1].title)
    end)

    it('reminds for in_progress overdue task', function()
        local task = Task.create("In progress task", "in_progress")
        task.due_at = os.time() - 600
        task_service:save_task(task)

        reminder_service:check_overdue_tasks()

        assert.stub(show_stub).was_called(1)
    end)

    it('suppresses repeat reminder within interval', function()
        local task = Task.create("Overdue task")
        task.due_at = os.time() - 600
        task_service:save_task(task)

        reminder_service:check_overdue_tasks()
        assert.stub(show_stub).was_called(1)

        -- Second check should be suppressed (within remind_interval)
        reminder_service:check_overdue_tasks()
        assert.stub(show_stub).was_called(1)
    end)

    it('reminds again after remind_interval has passed', function()
        local task = Task.create("Overdue task")
        task.due_at = os.time() - 600
        task_service:save_task(task)

        reminder_service:check_overdue_tasks()
        assert.stub(show_stub).was_called(1)

        -- Simulate time passing by backdating the reminded_at
        reminder_service._reminded_at[task.id] = os.time() - 301
        reminder_service:check_overdue_tasks()
        assert.stub(show_stub).was_called(2)
    end)

    it('reminds for multiple overdue tasks at once', function()
        local task1 = Task.create("Overdue 1")
        task1.due_at = os.time() - 600
        task_service:save_task(task1)

        local task2 = Task.create("Overdue 2")
        task2.due_at = os.time() - 900
        task_service:save_task(task2)

        reminder_service:check_overdue_tasks()

        assert.stub(show_stub).was_called(1)
        local args = show_stub.calls[1].refs
        assert.are.equal(2, #args[2])
    end)
end)
