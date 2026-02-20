local init = require('agenda.init')
local epic_controller = require('agenda.controller.epic')
local input_controller = require('agenda.controller.input')
local render_controller = require('agenda.controller.render')
local epic_store = require('agenda.model.entity.epic_store')
local epic_ui_state = require('agenda.model.ui.epic_ui_state')
local task_store = require('agenda.model.entity.task_store')
local task_service = require('agenda.service.task_service')
local Task = require('agenda.model.entity.task')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')
local stub = require("luassert.stub")

init:setup()

describe('Integration tests for epics', function()
    before_each(function()
        file_utils:remove_files_from_folder(global_config.workspace_epic_path)
        file_utils:remove_files_from_folder(global_config.workspace_task_path)
        epic_store:reset()
        epic_ui_state:reset()
        task_store:reset()
    end)

    describe('Creating epic', function()
        it('Epic is created, GUI is shut down and reopened, then epic is removed', function()
            vim.cmd('Agenda epics')
            epic_controller:create_epic("Test epic")
            render_controller:destroy()
            assert.are.equal(1, epic_store:get_epic_count())
            assert.are.equal("Test epic", epic_store:get_epics()[1].name)

            -- Reopen GUI
            vim.cmd('Agenda epics')
            epic_controller:remove_epic()
            render_controller:destroy()
            assert.are.equal(0, epic_store:get_epic_count())
        end)

        it('Two epics will be created and the first epic will be removed, then the second', function()
            vim.cmd('Agenda epics')
            epic_controller:create_epic("Test epic")
            assert.are.equal(1, epic_store:get_epic_count())
            assert.are.equal("Test epic", epic_store:get_epics()[1].name)

            epic_controller:create_epic("Test epic2")
            assert.are.equal(2, epic_store:get_epic_count())
            assert.are.equal("Test epic2", epic_store:get_epics()[2].name)

            epic_controller:move_up()
            epic_controller:remove_epic()
            assert.are.equal(1, epic_store:get_epic_count())
            assert.are.equal("Test epic2", epic_store:get_epics()[1].name)

            epic_controller:remove_epic()
            assert.are.equal(0, epic_store:get_epic_count())

            render_controller:destroy()
        end)

        it('Deleting epic clears epic_id from all associated tasks', function()
            vim.cmd('Agenda epics')
            epic_controller:create_epic("Test epic")
            local epic = epic_store:get_epics()[1]

            -- Create tasks associated with the epic
            local task1 = Task.create("Task 1")
            task1 = Task.with_epic(task1, epic.id)
            task_service:save_task(task1)
            task_store:add_task(task1)

            local task2 = Task.create("Task 2")
            task2 = Task.with_epic(task2, epic.id)
            task_service:save_task(task2)
            task_store:add_task(task2)

            -- Create a task without epic
            local task3 = Task.create("Task 3")
            task_service:save_task(task3)
            task_store:add_task(task3)

            -- Verify tasks have epic_id
            assert.are.equal(epic.id, task_store:get_tasks()[1].epic_id)
            assert.are.equal(epic.id, task_store:get_tasks()[2].epic_id)
            assert.is_nil(task_store:get_tasks()[3].epic_id)

            -- Delete the epic
            epic_controller:remove_epic()

            -- Verify all tasks now have nil epic_id
            assert.is_nil(task_store:get_tasks()[1].epic_id)
            assert.is_nil(task_store:get_tasks()[2].epic_id)
            assert.is_nil(task_store:get_tasks()[3].epic_id)

            render_controller:destroy()
        end)
    end)

    describe('Renaming epic', function()
        local mocked
        before_each(function()
            mocked = stub(input_controller, 'get_value')
            mocked.returns("Test epic renamed")
        end)

        after_each(function()
            if mocked then
                mocked:revert()
                mocked = nil
            end
        end)

        it('Epic will be created and renamed', function()
            vim.cmd('Agenda epics')
            epic_controller:create_epic("Test epic")
            epic_controller:do_action()
            epic_controller:do_action()

            input_controller:close_edit()

            render_controller:destroy()
            assert.are.equal(1, epic_store:get_epic_count())
            assert.are.equal("Test epic renamed", epic_store:get_epics()[1].name)
        end)

        it('Epic will be created and rename will be cancelled at input', function()
            vim.cmd('Agenda epics')
            epic_controller:create_epic("Test epic")
            epic_controller:do_action()
            epic_controller:do_action()

            input_controller:cancel_edit()

            render_controller:destroy()
            assert.are.equal(1, epic_store:get_epic_count())
            assert.are.equal("Test epic", epic_store:get_epics()[1].name)
        end)
    end)

    describe('Epic description', function()
        local mocked
        before_each(function()
            mocked = stub(input_controller, 'get_value')
            mocked.returns("Epic description text")
        end)

        after_each(function()
            if mocked then
                mocked:revert()
                mocked = nil
            end
        end)

        it('Epic description can be edited via multiline input', function()
            vim.cmd('Agenda epics')
            epic_controller:create_epic("Test epic")
            -- Enter detail view
            epic_controller:do_action()
            -- Move to description line
            epic_controller:detail_move_down()
            -- Edit description
            epic_controller:do_action()

            input_controller:close_edit()

            render_controller:destroy()
            assert.are.equal(1, epic_store:get_epic_count())
            assert.are.equal("Epic description text", epic_store:get_epics()[1].description)
        end)
    end)
end)
