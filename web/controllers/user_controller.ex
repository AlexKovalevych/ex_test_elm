defmodule Gt.UserController do
    use Gt.Web, :controller
    require Gt.AuthController
    alias Gt.Manager.Users

    plug Gt.Guardian.EnsureAuthenticated, handler: Gt.AuthController

    def list(conn, _) do
        initial_state = %{
            users: Users.load_users(1)
        }
        Gt.AuthController.render_elm(conn, initial_state, true)
    end

    def create(conn, _) do
        [users_state, permissions_state] = Users.load_user
        initial_state = %{
            users: Map.merge(Users.load_users(1), users_state),
            permissions: permissions_state
        }
        Gt.AuthController.render_elm(conn, initial_state, true)
    end

    def edit(conn, %{"id" => id}) do
        [users_state, permissions_state] = Users.load_user(id)
        initial_state = %{
            users: Map.merge(Users.load_users(1), users_state),
            permissions: permissions_state
        }
        Gt.AuthController.render_elm(conn, initial_state, true)
    end
end
