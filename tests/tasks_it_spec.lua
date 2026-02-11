local init = require('agenda.init')
local task_controller = require('agenda.controller.task')
local input_controller = require('agenda.controller.input')
local calendar_controller = require('agenda.controller.calendar')
local calendar_model = require('agenda.model.entity.calendar')
local render_controller = require('agenda.controller.render')
local task_store = require('agenda.model.entity.task_store')
local task_ui_state = require('agenda.model.ui.task_ui_state')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')
local Task = require('agenda.model.entity.task')
local stub = require("luassert.stub")

init:setup()

describe('Integration tests for tasks', function()
    before_each(function()
        file_utils:remove_files_from_folder(global_config.workspace_task_path)
        task_store:reset()
        task_ui_state:reset()
    end)

    describe('Creating task', function()
        it('Task is created, GUI is shut down and reopened, then task is removed', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            render_controller:destroy()
            assert.are.equal(1, task_store:get_task_count())
            assert.are.equal("Test task", task_store:get_tasks()[1].title)

            -- Reopen GUI
            vim.cmd('Agenda tasks')
            task_controller:remove_task()
            render_controller:destroy()
            assert.are.equal(0, task_store:get_task_count())
        end)
        it('Two tasks will be created and the first task will be removed, then the second', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            assert.are.equal(1, task_store:get_task_count())
            assert.are.equal("Test task", task_store:get_tasks()[1].title)

            task_controller:create_task("Test task2")
            assert.are.equal(2, task_store:get_task_count())
            assert.are.equal("Test task2", task_store:get_tasks()[2].title)

            task_controller:move_up()
            task_controller:remove_task()
            assert.are.equal(1, task_store:get_task_count())
            assert.are.equal("Test task2", task_store:get_tasks()[1].title)

            task_controller:remove_task()
            assert.are.equal(0, task_store:get_task_count())

            render_controller:destroy()
        end)
        it('Two tasks will be created, second task will be removed, then the first', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            assert.are.equal(1, task_store:get_task_count())
            assert.are.equal("Test task", task_store:get_tasks()[1].title)

            task_controller:create_task("Test task2")
            assert.are.equal(2, task_store:get_task_count())
            assert.are.equal("Test task2", task_store:get_tasks()[2].title)

            task_controller:remove_task()
            assert.are.equal(1, task_store:get_task_count())
            assert.are.equal("Test task", task_store:get_tasks()[1].title)

            task_controller:remove_task()
            assert.are.equal(0, task_store:get_task_count())

            render_controller:destroy()
        end)
    end)


    describe('Renaming task', function()
        local mocked
        before_each(function()
            mocked = stub(input_controller, 'get_value')
            mocked.returns("Test task renamed")
        end)

        after_each(function()
            if mocked then
                mocked:revert()
                mocked = nil
            end
        end)

        it('Task will be created and renamed', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            task_controller:do_action()
            task_controller:do_action()

            input_controller:close_edit()

            render_controller:destroy()
            assert.are.equal(1, task_store:get_task_count())
            assert.are.equal("Test task renamed", task_store:get_tasks()[1].title)
        end)

        it('Task will be created and rename will be cancelled at input', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            task_controller:do_action()
            task_controller:do_action()

            input_controller:cancel_edit()

            render_controller:destroy()
            assert.are.equal(1, task_store:get_task_count())
            assert.are.equal("Test task", task_store:get_tasks()[1].title)
        end)
    end)

    describe('Changing task status with select input', function()
        it('Task status will be changed to in_progress', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            assert.are.equal("todo", task_store:get_tasks()[1].status)

            -- Navigate to detail view
            task_controller:do_action()
            -- Move to status line
            task_controller:detail_move_down()
            -- Open select input
            task_controller:do_action()

            -- Select next option (in_progress)
            input_controller:select_next()
            input_controller:close_edit()

            render_controller:destroy()
            assert.are.equal(1, task_store:get_task_count())
            assert.are.equal("in_progress", task_store:get_tasks()[1].status)
        end)

        it('Task status will be changed to done', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            assert.are.equal("todo", task_store:get_tasks()[1].status)

            -- Navigate to detail view
            task_controller:do_action()
            -- Move to status line
            task_controller:detail_move_down()
            -- Open select input
            task_controller:do_action()

            -- Select next option twice (in_progress -> done)
            input_controller:select_next()
            input_controller:select_next()
            input_controller:close_edit()

            render_controller:destroy()
            assert.are.equal(1, task_store:get_task_count())
            assert.are.equal("done", task_store:get_tasks()[1].status)
        end)

        it('Task status change will be cancelled', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            assert.are.equal("todo", task_store:get_tasks()[1].status)

            -- Navigate to detail view
            task_controller:do_action()
            -- Move to status line
            task_controller:detail_move_down()
            -- Open select input
            task_controller:do_action()

            -- Select next option but cancel
            input_controller:select_next()
            input_controller:cancel_edit()

            render_controller:destroy()
            assert.are.equal(1, task_store:get_task_count())
            assert.are.equal("todo", task_store:get_tasks()[1].status)
        end)

        it('Select prev does not go below first option', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")

            -- Navigate to detail view
            task_controller:do_action()
            -- Move to status line
            task_controller:detail_move_down()
            -- Open select input
            task_controller:do_action()

            -- Try to go before first option
            input_controller:select_prev()
            input_controller:close_edit()

            render_controller:destroy()
            assert.are.equal("todo", task_store:get_tasks()[1].status)
        end)

        it('Select next does not go past last option', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")

            -- Navigate to detail view
            task_controller:do_action()
            -- Move to status line
            task_controller:detail_move_down()
            -- Open select input
            task_controller:do_action()

            -- Try to go past last option (todo -> in_progress -> done -> done)
            input_controller:select_next()
            input_controller:select_next()
            input_controller:select_next()
            input_controller:select_next()
            input_controller:close_edit()

            render_controller:destroy()
            assert.are.equal("done", task_store:get_tasks()[1].status)
        end)

        it('Select can navigate back and forth', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")

            -- Navigate to detail view
            task_controller:do_action()
            -- Move to status line
            task_controller:detail_move_down()
            -- Open select input
            task_controller:do_action()

            -- Navigate: todo -> in_progress -> done -> in_progress
            input_controller:select_next()
            input_controller:select_next()
            input_controller:select_prev()
            input_controller:close_edit()

            render_controller:destroy()
            assert.are.equal("in_progress", task_store:get_tasks()[1].status)
        end)
    end)

    describe('Task timestamps', function()
        it('created_at is set on task creation', function()
            vim.cmd('Agenda tasks')
            local before = os.time()
            task_controller:create_task("Test task")
            local after = os.time()

            local task = task_store:get_tasks()[1]
            assert.is_not_nil(task.created_at)
            assert.is_true(task.created_at >= before)
            assert.is_true(task.created_at <= after)
            assert.is_nil(task.due_at)

            render_controller:destroy()
        end)

        it('created_at persists after reload', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            local original_created_at = task_store:get_tasks()[1].created_at

            render_controller:destroy()

            -- Reopen
            vim.cmd('Agenda tasks')
            local task = task_store:get_tasks()[1]
            assert.are.equal(original_created_at, task.created_at)

            render_controller:destroy()
        end)

        it('due_at is set via calendar confirm and persists', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")

            -- Navigate to detail view
            task_controller:do_action()
            -- Move to Due line (line index 6)
            task_controller:detail_move_down() -- 1 -> 2
            task_controller:detail_move_down() -- 2 -> 3
            task_controller:detail_move_down() -- 3 -> 4
            task_controller:detail_move_down() -- 4 -> 5
            task_controller:detail_move_down() -- 5 -> 6
            -- Open calendar
            task_controller:do_action()

            -- Confirm the calendar (takes current time as default)
            calendar_controller:confirm()

            local task = task_store:get_tasks()[1]
            assert.is_not_nil(task.due_at)
            assert.is_number(task.due_at)

            render_controller:destroy()
        end)

        it('due_at is cleared via calendar clear', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")

            -- First set a due date
            task_controller:do_action()
            task_controller:detail_move_down()
            task_controller:detail_move_down()
            task_controller:detail_move_down()
            task_controller:detail_move_down()
            task_controller:detail_move_down()
            task_controller:do_action()
            calendar_controller:confirm()

            assert.is_not_nil(task_store:get_tasks()[1].due_at)

            -- Now clear it
            task_controller:do_action()
            task_controller:detail_move_down()
            task_controller:detail_move_down()
            task_controller:detail_move_down()
            task_controller:detail_move_down()
            task_controller:detail_move_down()
            task_controller:do_action()
            calendar_controller:clear()

            local task = task_store:get_tasks()[1]
            assert.is_nil(task.due_at)

            render_controller:destroy()
        end)

        it('due_at cancel does not change value', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")

            task_controller:do_action()
            task_controller:detail_move_down()
            task_controller:detail_move_down()
            task_controller:detail_move_down()
            task_controller:detail_move_down()
            task_controller:detail_move_down()
            task_controller:do_action()
            calendar_controller:cancel()

            assert.is_nil(task_store:get_tasks()[1].due_at)

            render_controller:destroy()
        end)

        it('with_due_at preserves other fields', function()
            local task = Task.create("Test")
            task.project_id = "some-project"
            task.description = "some desc"

            local due = os.time()
            local updated = Task.with_due_at(task, due)

            assert.are.equal(task.id, updated.id)
            assert.are.equal(task.title, updated.title)
            assert.are.equal(task.status, updated.status)
            assert.are.equal(task.project_id, updated.project_id)
            assert.are.equal(task.description, updated.description)
            assert.are.equal(task.created_at, updated.created_at)
            assert.are.equal(due, updated.due_at)
        end)
    end)
end)
