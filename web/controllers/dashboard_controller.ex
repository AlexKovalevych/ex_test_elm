defmodule Gt.DashboardController do
    use Gt.Web, :controller
    require Gt.AuthController
    alias Gt.Manager.Dashboard

    plug Gt.Guardian.EnsureAuthenticated, handler: Gt.AuthController

    def index(conn, _) do
        initial_state = %{
            pendingTasks: 1,
            dashboard: current_user(conn) |> Dashboard.load_data
        }
        Gt.AuthController.render_elm(conn, initial_state)
    end
end
