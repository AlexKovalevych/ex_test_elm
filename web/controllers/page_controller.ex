defmodule Gt.PageController do
    use Gt.Web, :controller
    alias Gt.Model.User

    def login(conn, _params) do
        conn = conn |> fetch_session
        user_id = get_session(conn, :current_user)
        if !is_nil(user_id) do
            user = User
            |> User.by_id(user_id)
            |> Repo.one
            if !is_nil(user) do
                redirect conn, to: "/"
            else
                render_login(conn)
            end
        else
            render_login(conn)
        end
    end

    defp render_login(conn) do
        initial_state = %{}
        props = %{
            "location" => conn.request_path,
            "initial_state" => initial_state,
            "user_agent" => conn |> get_req_header("user-agent") |> Enum.at(0)
        }

        {:ok, result} = Gt.ReactIO.json_call(%{
            component: "./priv/static/server/js/app.js",
            props: props,
        })

        render(conn, "index.html", html: result["html"], props: Poison.encode!(props))
    end

    def index(conn, _params) do
        conn = conn |> fetch_session
        user_id = get_session(conn, :current_user)

        if is_nil(user_id) do
            redirect conn, to: "/login"
        else
            user = User
            |> User.by_id(user_id)
            |> Repo.one
            if is_nil(user) do
                redirect conn, to: "/login"
            else
                initial_state = %{"auth" => %{"user" => user}}
                props = %{
                    "location" => conn.request_path,
                    "initial_state" => initial_state,
                    "user_agent" => conn |> get_req_header("user-agent") |> Enum.at(0)
                }

                {:ok, result} = Gt.ReactIO.json_call(%{
                    component: "./priv/static/server/js/app.js",
                    props: props,
                })

                render(conn, "index.html", html: result["html"], props: Poison.encode!(props))
            end
        end
    end
end

