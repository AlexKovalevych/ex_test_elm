defmodule Gt.Api.V1.AuthController do
    use Gt.Web, :controller
    alias Gt.Model.User
    import Gt.Manager.TwoFactor, only: [verify_code: 2, generate_code: 1, google_qrcode_url: 1]
    import Ecto.Changeset

    # plug :scrub_params, "auth" when action in [:auth]

    def save_to_session(conn, k, v) do
        conn
        |> fetch_session
        |> put_session(k, v)
    end

    def auth(conn, %{"email" => email, "password" => password}) do
        case User.signin(email, password) do
            {:ok, user} ->
                conn = save_to_session(conn, :current_user, user.id)
                {conn, user} = cond do
                    User.no_two_factor(user) -> {save_to_session(conn, :is_two_factor, true), user}
                    true -> {conn, generate_code(user)}
                end
                if User.no_two_factor(user) do
                    login_success(conn, user)
                else
                    user = User.secure_phone(user)
                    cond do
                        User.two_factor(user, :google) ->
                            conn
                            |> put_status(:created)
                            |> render(Gt.Api.V1.AuthView, "show.json",
                                url: google_qrcode_url(user),
                                user: user,
                                serverTime: :os.system_time(:milli_seconds)
                            )
                        User.two_factor(user, :sms) ->
                            conn
                            |> put_status(:created)
                            |> render(Gt.Api.V1.AuthView, "show.json", user: user)
                    end
                end
            {:error, error} -> login_error(conn, error)
        end
    end

    def two_factor(conn, %{"code" => code}) do
        conn = conn |> fetch_session
        user_id = get_session(conn, :current_user)

        if is_nil(user_id) do
            login_error(conn)
        else
            user = User
            |> User.by_id(user_id)
            |> Repo.one
            if is_nil(user) do
                login_error(conn)
            else
                case verify_code(user, code) do
                    :ok ->
                        conn = save_to_session(conn, :is_two_factor, true)
                        login_success(conn, user)
                    {:error, message} -> login_error(conn, message)
                end
            end
        end
    end

    def send_sms(conn, _params) do
        conn = conn |> fetch_session
        user_id = get_session(conn, :current_user)

        if is_nil(user_id) do
            login_error(conn)
        else
            user = User
            |> User.by_id(user_id)
            |> Repo.one
            if is_nil(user) do
                login_error(conn)
            else
                generate_code(user)
                conn |> send_resp(200, Poison.encode!(%{}))
            end
        end
    end

    def delete(conn, _) do
        conn = conn |> fetch_session
        user_id = get_session(conn, :current_user)
        case Guardian.Plug.claims(conn) do
            {:ok, claims} -> conn
                |> Guardian.Plug.current_token
                |> Guardian.revoke!(claims)
            {:error, _} -> conn
        end

        Gt.Endpoint.broadcast("users_socket:#{user_id}", "disconnect", %{})
        conn = clear_session(conn)
        conn
        |> render(Gt.Api.V1.AuthView, "delete.json")
    end

    def unauthenticated(conn, _params) do
        conn
        |> put_status(:forbidden)
        |> render(Gt.Api.V1.AuthView, "forbidden.json", error: "Not Authenticated")
    end

    defp login_error(conn, error \\ "Not authenticated") do
        conn
        |> put_status(:unprocessable_entity)
        |> render(Gt.Api.V1.AuthView, "error.json", error: error)
    end

    defp login_success(conn, user) do
        {:ok, jwt, _full_claims} = user |> Guardian.encode_and_sign(:token)
        user
        |> change(%{lastLogin: Ecto.DateTime.local})
        |> apply_changes
        |> Gt.Repo.update
        conn
        |> put_status(:created)
        |> render(Gt.Api.V1.AuthView, "show.json", jwt: jwt, user: user)
    end
end
