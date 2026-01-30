local init = require('agenda.init')
local task_controller = require('agenda.controller.task')
local input_controller = require('agenda.controller.input')
local render_controller = require('agenda.controller.render')
local task_repository = require('agenda.repository.task_repository')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')
local stub = require("luassert.stub")

init:setup()

describe('Integration tests for tasks', function()
    before_each(function()
        file_utils:remove_files_from_folder(global_config.workspace_task_path)
        task_repository:clear()
    end)

    describe('Creating task', function()
        it('Task will be created, gui shutdown and reopen and task will be then removed', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            render_controller:destroy()
            assert.are.equal(1, #task_repository:get_all())
            assert.is_true(task_repository:get_all()[1].title == "Test task")

            -- Reopen GUI
            vim.cmd('Agenda tasks')
            task_controller:remove_task()
            render_controller:destroy()
            assert.are.equal(0, #task_repository:get_all())
        end)
        it('Two tasks will be created and removed in the same order', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            assert.are.equal(1, #task_repository:get_all())
            assert.is_true(task_repository:get_all()[1].title == "Test task")

            task_controller:create_task("Test task2")
            assert.are.equal(2, #task_repository:get_all())
            assert.is_true(task_repository:get_all()[2].title == "Test task2")

            task_controller:move_up()
            task_controller:remove_task()
            assert.are.equal(1, #task_repository:get_all())
            assert.is_true(task_repository:get_all()[1].title == "Test task2")

            task_controller:remove_task()
            assert.are.equal(0, #task_repository:get_all())

            render_controller:destroy()
        end)
    end)


    describe('Renaming task', function()
        local mocked = stub(input_controller, 'get_value')
        mocked.returns("Test task renamed")

        it('Task will be created and renamed', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            task_controller:do_action()
            task_controller:do_action()

            input_controller:close_edit()

            render_controller:destroy()
            assert.are.equal(1, #task_repository:get_all())
            assert.is_true(task_repository:get_all()[1].title == "Test task renamed")
        end)

        it('Task will be created and rename will be cancelled at input', function()
            vim.cmd('Agenda tasks')
            task_controller:create_task("Test task")
            task_controller:do_action()
            task_controller:do_action()

            input_controller:cancel_edit()

            render_controller:destroy()
            assert.are.equal(1, #task_repository:get_all())
            assert.is_true(task_repository:get_all()[1].title == "Test task")
        end)
    end)
end)
