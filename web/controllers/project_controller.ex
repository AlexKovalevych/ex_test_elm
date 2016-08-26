defmodule Gt.ProjectController do
    use Gt.Web, :controller
    require Gt.AuthController
    alias Gt.Manager.Projects

    plug Gt.Guardian.EnsureAuthenticated, handler: Gt.AuthController

    def list(conn, _) do
        initial_state = %{
            projects: Projects.load_projects(1)
        }
        Gt.AuthController.render_elm(conn, initial_state, true)
    end

    def edit(conn, %{"id" => id}) do
        initial_state = %{
            projects: Map.merge(Projects.load_projects(1), Projects.load_project(id))
        }
        Gt.AuthController.render_elm(conn, initial_state, true)
    end
end
