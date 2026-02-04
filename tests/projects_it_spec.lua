local init = require('agenda.init')
local project_controller = require('agenda.controller.project')
local input_controller = require('agenda.controller.input')
local render_controller = require('agenda.controller.render')
local project_store = require('agenda.model.entity.project_store')
local project_ui_state = require('agenda.model.ui.project_ui_state')
local global_config = require('agenda.config.global')
local file_utils = require('agenda.util.file')
local stub = require("luassert.stub")

init:setup()

describe('Integration tests for projects', function()
    before_each(function()
        file_utils:remove_files_from_folder(global_config.workspace_project_path)
        project_store:reset()
        project_ui_state:reset()
    end)

    describe('Creating project', function()
        it('Project is created, GUI is shut down and reopened, then project is removed', function()
            vim.cmd('Agenda project')
            project_controller:create_project("Test project")
            render_controller:destroy()
            assert.are.equal(1, project_store:get_project_count())
            assert.are.equal("Test project", project_store:get_projects()[1].name)

            -- Reopen GUI
            vim.cmd('Agenda project')
            project_controller:remove_project()
            render_controller:destroy()
            assert.are.equal(0, project_store:get_project_count())
        end)

        it('Two projects will be created and the first project will be removed, then the second', function()
            vim.cmd('Agenda project')
            project_controller:create_project("Test project")
            assert.are.equal(1, project_store:get_project_count())
            assert.are.equal("Test project", project_store:get_projects()[1].name)

            project_controller:create_project("Test project2")
            assert.are.equal(2, project_store:get_project_count())
            assert.are.equal("Test project2", project_store:get_projects()[2].name)

            project_controller:move_up()
            project_controller:remove_project()
            assert.are.equal(1, project_store:get_project_count())
            assert.are.equal("Test project2", project_store:get_projects()[1].name)

            project_controller:remove_project()
            assert.are.equal(0, project_store:get_project_count())

            render_controller:destroy()
        end)
    end)

    describe('Renaming project', function()
        local mocked
        before_each(function()
            mocked = stub(input_controller, 'get_value')
            mocked.returns("Test project renamed")
        end)

        after_each(function()
            if mocked then
                mocked:revert()
                mocked = nil
            end
        end)

        it('Project will be created and renamed', function()
            vim.cmd('Agenda project')
            project_controller:create_project("Test project")
            project_controller:do_action()
            project_controller:do_action()

            input_controller:close_edit()

            render_controller:destroy()
            assert.are.equal(1, project_store:get_project_count())
            assert.are.equal("Test project renamed", project_store:get_projects()[1].name)
        end)

        it('Project will be created and rename will be cancelled at input', function()
            vim.cmd('Agenda project')
            project_controller:create_project("Test project")
            project_controller:do_action()
            project_controller:do_action()

            input_controller:cancel_edit()

            render_controller:destroy()
            assert.are.equal(1, project_store:get_project_count())
            assert.are.equal("Test project", project_store:get_projects()[1].name)
        end)
    end)
end)
