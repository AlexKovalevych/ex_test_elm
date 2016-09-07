defmodule Gt.Manager.TwoFactor do
    import Plug.Conn
    import Ecto.Changeset

    @server "Globotunes"
    @failed_login_limit 6
    @sms_length 8
    @code_variance 2

    def fully_authenticated(conn) do
        user_id = get_session(conn, :current_user)
        is_two_factor = get_session(conn, :is_two_factor)
        !is_nil(user_id) && !is_nil(is_two_factor)
    end

    def verify_code(user, code) do
        if user.failedLoginCount > @failed_login_limit do
            {:error, "login.disabled"}
        else
            case user.authenticationType do
                "sms" ->
                    if user.smsCode == code do
                        success_code(user)
                    else
                        error_code(user)
                        {:error, "invalid_sms_code"}
                    end
                "google" ->
                    if :pot.valid_totp(code, user.googleSecret) do
                        user = user
                        |> change(%{showGoogleCode: false})
                        |> apply_changes
                        success_code(user)
                    else
                        error_code(user)
                        {:error, "invalid_google_code"}
                    end
            end
        end
    end

    defp success_code(user) do
        user
        |> change(%{failedLoginCount: 0})
        |> apply_changes
        |> Gt.Repo.update
        :ok
    end

    defp error_code(user) do
        changeset = %{failedLoginCount: user.failedLoginCount + 1}
        changeset = case changeset.failedLoginCount >= @failed_login_limit do
            true -> Map.put(changeset, :enabled, false)
            false -> changeset
        end
        user
        |> change(changeset)
        |> apply_changes
        |> Gt.Repo.update
    end

    @spec generate_code(Gt.Model.User) :: Gt.Model.User
    def generate_code(user) do
        case user.authenticationType do
            "sms" ->
                code_length = @sms_length - @code_variance + :rand.uniform(@code_variance * 2)
                code = to_string for _ <- 1..code_length, do: to_string(:rand.uniform(10) - 1)
                {:ok, user} = user
                |> change(%{smsCode: code})
                |> apply_changes
                |> Gt.Repo.update
                message = %Gt.Amqp.Messages.Sms{
                    phone: user.phoneNumber,
                    clientId: :os.system_time(:seconds),
                    text: code
                }
                GenServer.cast(GtAmqpDefault, {:iqsms, Poison.encode!(message)})
                user
            "google" ->
                case !user.googleSecret do
                    true ->
                        {:ok, user} = user
                        |> change(%{googleSecret: generate_google_secret})
                        |> apply_changes
                        |> Gt.Repo.update
                        user
                    false -> user
                end
        end
    end

    def generate_google_secret do
        :crypto.strong_rand_bytes(10) |> Base.encode32
    end

    def google_qrcode_url(user) do
        if user.showGoogleCode do
            "https://chart.googleapis.com/chart?cht=qr&chs=200x200&chl=" <>
            URI.encode_www_form("otpauth://totp/#{@server}:#{user.email}?secret=#{user.googleSecret}")
        else
            nil
        end
    end
end
