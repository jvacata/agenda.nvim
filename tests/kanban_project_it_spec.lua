local init = require('agenda.init')
local task_controller = require('agenda.controller.task')
local project_controller = require('agenda.controller.project')
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
local project_service = require('agenda.service.project_service')
local Project = require('agenda.model.entity.project')

init:setup()

describe('Integration tests for kanban project filtering', function()
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

    describe('Kanban shows tasks filtered by project', function()
        it('Unlisted shows only tasks without project', function()
            -- Create a project
            local project = Project.create("Test Project")
            project_service:save_project(project)
            project_store:add_project(project)

            -- Create tasks - one with project, one without
            local task_with_project = Task.create("Task with project")
            task_with_project = Task.with_project(task_with_project, project.id)
            task_service:save_task(task_with_project)
            task_store:add_task(task_with_project)

            local task_without_project = Task.create("Task without project")
            task_service:save_task(task_without_project)
            task_store:add_task(task_without_project)

            -- Open kanban (starts at Unlisted)
            vim.cmd('Agenda kanban')

            -- Get view data - should only show task without project
            local view_data = kanban_controller:get_view_data()
            local open_tasks = view_data.columns["open"]

            assert.are.equal(1, #open_tasks)
            assert.are.equal("Task without project", open_tasks[1].title)

            render_controller:destroy()
        end)

        it('Project filter shows only tasks for that project', function()
            -- Create a project
            local project = Project.create("Test Project")
            project_service:save_project(project)
            project_store:add_project(project)

            -- Create tasks - one with project, one without
            local task_with_project = Task.create("Task with project")
            task_with_project = Task.with_project(task_with_project, project.id)
            task_service:save_task(task_with_project)
            task_store:add_task(task_with_project)

            local task_without_project = Task.create("Task without project")
            task_service:save_task(task_without_project)
            task_store:add_task(task_without_project)

            -- Open kanban
            vim.cmd('Agenda kanban')

            -- Move to project in list (index 1 = first project after Unlisted)
            kanban_controller:project_move_down()

            -- Get view data - should only show task with project
            local view_data = kanban_controller:get_view_data()
            local open_tasks = view_data.columns["open"]

            assert.are.equal(1, #open_tasks)
            assert.are.equal("Task with project", open_tasks[1].title)

            render_controller:destroy()
        end)

        it('Multiple projects filter correctly', function()
            -- Create two projects
            local project1 = Project.create("Project 1")
            project_service:save_project(project1)
            project_store:add_project(project1)

            local project2 = Project.create("Project 2")
            project_service:save_project(project2)
            project_store:add_project(project2)

            -- Create tasks for each project
            local task1 = Task.create("Task for Project 1")
            task1 = Task.with_project(task1, project1.id)
            task_service:save_task(task1)
            task_store:add_task(task1)

            local task2 = Task.create("Task for Project 2")
            task2 = Task.with_project(task2, project2.id)
            task_service:save_task(task2)
            task_store:add_task(task2)

            -- Open kanban
            vim.cmd('Agenda kanban')

            -- Check Unlisted (should be empty)
            local view_data = kanban_controller:get_view_data()
            assert.are.equal(0, #view_data.columns["open"])

            -- Move to Project 1
            kanban_controller:project_move_down()
            view_data = kanban_controller:get_view_data()
            assert.are.equal(1, #view_data.columns["open"])
            assert.are.equal("Task for Project 1", view_data.columns["open"][1].title)

            -- Move to Project 2
            kanban_controller:project_move_down()
            view_data = kanban_controller:get_view_data()
            assert.are.equal(1, #view_data.columns["open"])
            assert.are.equal("Task for Project 2", view_data.columns["open"][1].title)

            render_controller:destroy()
        end)
    end)

    describe('Kanban project navigation', function()
        it('Can switch focus from project list to board and back', function()
            vim.cmd('Agenda kanban')

            -- Should start in project list
            assert.are.equal("project_list", kanban_ui_state:get_focus())

            -- Enter to switch to board
            kanban_controller:project_enter()
            assert.are.equal("board", kanban_ui_state:get_focus())

            -- Q to switch back to project list
            kanban_controller:handle_q()
            assert.are.equal("project_list", kanban_ui_state:get_focus())

            render_controller:destroy()
        end)

        it('Project list shows Unlisted plus all projects', function()
            -- Create projects
            local project1 = Project.create("Alpha Project")
            project_service:save_project(project1)
            project_store:add_project(project1)

            local project2 = Project.create("Beta Project")
            project_service:save_project(project2)
            project_store:add_project(project2)

            vim.cmd('Agenda kanban')

            local view_data = kanban_controller:get_view_data()

            assert.are.equal(3, #view_data.project_list)
            assert.are.equal("Unlisted", view_data.project_list[1])
            assert.are.equal("Alpha Project", view_data.project_list[2])
            assert.are.equal("Beta Project", view_data.project_list[3])

            render_controller:destroy()
        end)
    end)
end)
