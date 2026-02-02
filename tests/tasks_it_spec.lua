local init = require('agenda.init')
local task_controller = require('agenda.controller.task')
local input_controller = require('agenda.controller.input')
local render_controller = require('agenda.controller.render')
local task_store = require('agenda.model.entity.task_store')
local task_ui_state = require('agenda.model.ui.task_ui_state')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')
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
end)
