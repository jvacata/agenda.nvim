local init = require('agenda.init')
local kanban_controller = require('agenda.controller.kanban')
local render_controller = require('agenda.controller.render')
local task_store = require('agenda.model.entity.task_store')
local task_ui_state = require('agenda.model.ui.task_ui_state')
local project_store = require('agenda.model.entity.project_store')
local project_ui_state = require('agenda.model.ui.project_ui_state')
local kanban_store = require('agenda.model.entity.kanban_store')
local kanban_ui_state = require('agenda.model.ui.kanban_ui_state')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')
local Task = require('agenda.model.entity.task')
local task_service = require('agenda.service.task_service')

init:setup()

describe('Integration tests for kanban task move', function()
    before_each(function()
        file_utils:remove_files_from_folder(global_config.workspace_task_path)
        file_utils:remove_files_from_folder(global_config.workspace_project_path)
        task_store:reset()
        task_ui_state:reset()
        project_store:reset()
        project_ui_state:reset()
        kanban_store:reset()
        kanban_ui_state:reset()
    end)

    describe('Pick up task', function()
        it('CR sets moving_task_id when a task is selected', function()
            local task = Task.create("My task")
            task_service:save_task(task)
            task_store:add_task(task)

            vim.cmd('Agenda kanban')
            kanban_controller:project_enter()

            -- Should have a task selected in open column
            local view_data = kanban_controller:get_view_data()
            assert.are.equal(0, view_data.selected_row)
            assert.is_nil(view_data.moving_task_id)

            -- Pick up
            kanban_controller:handle_enter()

            view_data = kanban_controller:get_view_data()
            assert.are.equal(task.id, view_data.moving_task_id)

            render_controller:destroy()
        end)

        it('CR does nothing when no task is selected', function()
            vim.cmd('Agenda kanban')
            kanban_controller:project_enter()

            -- No tasks, selected_row should be nil
            local view_data = kanban_controller:get_view_data()
            assert.is_nil(view_data.selected_row)

            kanban_controller:handle_enter()

            view_data = kanban_controller:get_view_data()
            assert.is_nil(view_data.moving_task_id)

            render_controller:destroy()
        end)
    end)

    describe('Task visually moves during moving phase', function()
        it('Task appears in target column while moving', function()
            local task = Task.create("My task")
            task_service:save_task(task)
            task_store:add_task(task)

            vim.cmd('Agenda kanban')
            kanban_controller:project_enter()

            -- Pick up
            kanban_controller:handle_enter()

            -- Task still shown in open column (same column)
            local view_data = kanban_controller:get_view_data()
            assert.are.equal(1, #view_data.columns["open"])
            assert.are.equal(0, #view_data.columns["in_progress"])

            -- Move to in_progress column
            kanban_controller:move_right()

            -- Task should now appear in in_progress, not in open
            view_data = kanban_controller:get_view_data()
            assert.are.equal(0, #view_data.columns["open"])
            assert.are.equal(1, #view_data.columns["in_progress"])
            assert.are.equal(task.id, view_data.columns["in_progress"][1].id)

            render_controller:destroy()
        end)

        it('j/k are no-ops while moving', function()
            local task1 = Task.create("Task 1")
            task_service:save_task(task1)
            task_store:add_task(task1)

            local task2 = Task.create("Task 2")
            task_service:save_task(task2)
            task_store:add_task(task2)

            vim.cmd('Agenda kanban')
            kanban_controller:project_enter()

            -- Select first task and pick up
            assert.are.equal(0, kanban_ui_state:get_selected_row())
            kanban_controller:handle_enter()

            -- j should not change row
            kanban_controller:move_down()
            assert.are.equal(0, kanban_ui_state:get_selected_row())

            -- k should not change row
            kanban_controller:move_up()
            assert.are.equal(0, kanban_ui_state:get_selected_row())

            render_controller:destroy()
        end)
    end)

    describe('Drop task', function()
        it('Moving task to another column changes its status', function()
            local task = Task.create("My task")
            task_service:save_task(task)
            task_store:add_task(task)

            vim.cmd('Agenda kanban')
            kanban_controller:project_enter()

            -- Pick up
            kanban_controller:handle_enter()

            -- Move to in_progress column
            kanban_controller:move_right()

            -- Drop
            kanban_controller:handle_enter()

            local view_data = kanban_controller:get_view_data()
            assert.is_nil(view_data.moving_task_id)

            -- Task should now be in in_progress column
            local in_progress_tasks = view_data.columns["in_progress"]
            assert.are.equal(1, #in_progress_tasks)
            assert.are.equal(task.id, in_progress_tasks[1].id)
            assert.are.equal("in_progress", in_progress_tasks[1].status)

            -- Open column should be empty
            assert.are.equal(0, #view_data.columns["open"])

            -- Task store should also be updated
            local stored_tasks = task_store:get_tasks()
            for _, t in ipairs(stored_tasks) do
                if t.id == task.id then
                    assert.are.equal("in_progress", t.status)
                end
            end

            render_controller:destroy()
        end)

        it('Moving task to same column is a no-op', function()
            local task = Task.create("My task")
            task_service:save_task(task)
            task_store:add_task(task)

            vim.cmd('Agenda kanban')
            kanban_controller:project_enter()

            -- Pick up
            kanban_controller:handle_enter()

            -- Drop on same column (open)
            kanban_controller:handle_enter()

            local view_data = kanban_controller:get_view_data()
            assert.is_nil(view_data.moving_task_id)

            -- Task should still be in open column with todo status
            local open_tasks = view_data.columns["open"]
            assert.are.equal(1, #open_tasks)
            assert.are.equal("todo", open_tasks[1].status)

            render_controller:destroy()
        end)
    end)

    describe('Cancel move', function()
        it('Q while moving cancels and restores selection to source column', function()
            local task = Task.create("My task")
            task_service:save_task(task)
            task_store:add_task(task)

            vim.cmd('Agenda kanban')
            kanban_controller:project_enter()

            -- Pick up from open column
            kanban_controller:handle_enter()
            assert.are.equal(task.id, kanban_ui_state:get_moving_task_id())

            -- Move to in_progress
            kanban_controller:move_right()
            assert.are.equal("in_progress", kanban_ui_state:get_selected_column())

            -- Cancel with q - should restore to original open column
            kanban_controller:handle_q()

            assert.is_nil(kanban_ui_state:get_moving_task_id())
            assert.are.equal("board", kanban_ui_state:get_focus())
            assert.are.equal("open", kanban_ui_state:get_selected_column())

            -- Task should be back in open column in view data
            local view_data = kanban_controller:get_view_data()
            assert.are.equal(1, #view_data.columns["open"])
            assert.are.equal(0, #view_data.columns["in_progress"])

            render_controller:destroy()
        end)

        it('Q without moving switches focus to project list', function()
            vim.cmd('Agenda kanban')
            kanban_controller:project_enter()
            assert.are.equal("board", kanban_ui_state:get_focus())

            kanban_controller:handle_q()
            assert.are.equal("project_list", kanban_ui_state:get_focus())

            render_controller:destroy()
        end)
    end)
end)
