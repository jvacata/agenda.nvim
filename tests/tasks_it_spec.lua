local init = require('agenda.init')
local task_controller = require('agenda.controller.task')
local input_controller = require('agenda.controller.input')
local render_controller = require('agenda.controller.render')
local task_repository = require('agenda.repository.task_repository')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')

init:setup()

describe('Integration tests for tasks', function()
    before_each(function()
        file_utils:remove_files_from_folder(global_config.workspace_task_path)
        task_repository:clear()
    end)

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

    it('Task will be created and renamed', function()
        vim.cmd('Agenda tasks')
        task_controller:create_task("Test task")
        task_controller:do_action()
        task_controller:do_action()

        input_controller:handle_input("Test task renamed")
        input_controller:close_edit()

        render_controller:destroy()
        assert.are.equal(1, #task_repository:get_all())
        assert.is_true(task_repository:get_all()[1].title == "Test task renamed")
    end)
end)
