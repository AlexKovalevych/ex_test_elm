defmodule Gt.Fixtures.User do
    alias Gt.Repo
    alias Gt.Model.{User, Project}
    import Gt.Manager.Permissions, only: [add: 3]
    import Gt.Manager.TwoFactor, only: [generate_code: 1]
    require Logger

    @permissions Application.get_env(:gt, :permissions)

    @users [
        {
            "alex@example.com",
            @permissions,
            "none",
            "06312345678",
            true
        },
        {
            "admin@example.com",
            @permissions,
            "sms",
            "06312345678",
            true
        },
        {
            "test@example.com",
            @permissions,
            "google",
            "06312345678",
            false
        }
    ]

    def run do
        Logger.info("Loading #{__MODULE__} fixtures")
        projects = Repo.all(Project)
        project_ids = Enum.map(projects, fn project -> project.id end)
        ParallelStream.map(@users, &insert_user(&1, project_ids)) |> Enum.to_list
        users = for n <- 1..20, do: {"user#{n}@example.com", @permissions, "none", "06312345678", false}
        ParallelStream.map(users, &insert_user(&1, project_ids)) |> Enum.to_list
        Logger.info("Loaded #{__MODULE__} fixtures")
    end

    def insert_user(user, project_ids) do
        {email, permissions, authenticated_type, phone, is_admin} = user;
        [pass, _] = String.split(email, "@")
        user = %{
            email: email,
            password_plain: pass,
            permissions: add(permissions, Map.keys(permissions), project_ids),
            is_admin: is_admin,
            phoneNumber: phone,
            authenticationType: authenticated_type
        }
        user = case authenticated_type do
            "sms" -> Map.put(user, :smsCode, "123")
            "google" -> Map.put(user, :showGoogleCode, true)
            "none" -> user
        end
        user = Repo.insert!(User.changeset(%User{}, user))
        if authenticated_type == 'google' do
            generate_code(user)
        end
    end
end
