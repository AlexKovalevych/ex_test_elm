defmodule Gt.AuthController do
    use Gt.Web, :controller
    alias Gt.Model.User

    defmacro render_elm(conn, initial_state, admin_required \\ false) do
        quote do
            conn = unquote conn
            admin_required = unquote admin_required
            current_user = current_user(conn)
            if !current_user.is_admin && admin_required do
                redirect conn, to: "/login"
            else
                initial_state = unquote initial_state
                initial_state = Map.put(initial_state, :auth, %{user: current_user})

                data = %{ getStorage: nil }


                # props = %{
                #     "location" => conn.request_path,
                #     "initial_state" => initial_state,
                #     "user_agent" => conn |> get_req_header("user-agent") |> Enum.at(0)
                # }

                {:ok, result} = Gt.ElmIo.json_call(%{
                    path: "./priv/static/server/js/app.js",
                    component: "Index",
                    render: "embed",
                    id: "index",
                    data: data,
                })

                render(conn, Gt.PageView, "index.html", html: result["html"], data: data)
            end
        end
    end

    def login(conn, _params) do
        conn = conn |> fetch_session
        user_id = get_session(conn, :current_user)
        is_two_factor = get_session(conn, :is_two_factor)
        if !is_nil(user_id) && !is_nil(is_two_factor) do
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

        {:ok, result} = Gt.ElmIo.json_call(%{
            component: "./priv/static/server/js/app.js",
            component: "Index",
            render: "embed",
            id: "index"
            # props: props,
        })

        render(conn, Gt.PageView, "index.html", html: result["html"], props: Poison.encode!(props))
    end

    def unauthenticated(conn, _params) do
        redirect conn, to: "/login"
    end
end
