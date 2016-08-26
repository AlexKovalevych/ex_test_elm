defmodule Gt.PageController do
    use Gt.Web, :controller
    require Gt.AuthController

    plug Gt.Guardian.EnsureAuthenticated, handler: Gt.AuthController

    def index(conn, _params) do
        Gt.AuthController.render_elm(conn, %{})
    end
end

