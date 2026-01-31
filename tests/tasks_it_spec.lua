local init = require('agenda.init')
local task_controller = require('agenda.controller.task')
local input_controller = require('agenda.controller.input')
local render_controller = require('agenda.controller.render')
local task_store = require('agenda.model.task_store')
local task_ui_state = require('agenda.model.task_ui_state')
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
end)
