defmodule Gt.UserChannel do
    use Gt.Web, :channel
    alias Gt.Model.User
    alias Gt.Manager.Dashboard
    alias Gt.Manager.Permissions

    def join("users:" <> user_id, _params, socket) do
        if user_id == socket.assigns.current_user do
            {:ok, socket}
        else
            {:error, %{reason: "Invalid user"}}
        end
    end

    def handle_in("dashboard_stats", params, socket) do
        current_user = Repo.get(User, socket.assigns.current_user)
        data = Dashboard.load_data(current_user, Map.get(params, "period"))
        {:reply, {:ok, data}, socket}
    end
    def handle_in("locale", locale, socket) do
        user = Repo.get(User, socket.assigns.current_user)
        user = Ecto.Changeset.change user, locale: locale
        response = case Repo.update user do
            {:ok, user} -> {:ok, user}
            {:error, changeset} -> {:error, %{reason: changeset}}
        end
        {:reply, response, socket}
    end
    def handle_in("dashboard_sort", sortBy, socket) do
        user = Repo.get(User, socket.assigns.current_user)
        settings = user.settings |> Map.put("dashboardSort", sortBy)
        user = Ecto.Changeset.change user, settings: settings
        response = case Repo.update user do
            {:ok, user} -> {:ok, user}
            {:error, changeset} -> {:error, %{reason: changeset}}
        end
        {:reply, response, socket}
    end
    def handle_in("dashboard_period", period, socket) do
        user = Repo.get(User, socket.assigns.current_user)
        settings = user.settings |> Map.put("dashboardPeriod", period)
        user = Ecto.Changeset.change user, settings: settings
        response = case Repo.update user do
            {:ok, user} -> {:ok, user}
            {:error, changeset} -> {:error, %{reason: changeset}}
        end
        {:reply, response, socket}
    end
    def handle_in("dashboard_comparison_period", period, socket) do
        user = Repo.get(User, socket.assigns.current_user)
        settings = user.settings |> Map.put("dashboardComparePeriod", String.to_integer(period))
        user = Ecto.Changeset.change user, settings: settings
        response = case Repo.update user do
            {:ok, user} -> {:ok, user}
            {:error, changeset} -> {:error, %{reason: changeset}}
        end
        {:reply, response, socket}
    end
    def handle_in("dashboard_projects_type", type, socket) do
        user = Repo.get(User, socket.assigns.current_user)
        settings = user.settings |> Map.put("dashboardProjectsType", type)
        user = Ecto.Changeset.change user, settings: settings
        response = case Repo.update user do
            {:ok, user} -> {:ok, user}
            {:error, changeset} -> {:error, %{reason: changeset}}
        end
        {:reply, response, socket}
    end
    def handle_in("consolidated_chart", params, socket) do
        current_user = Repo.get(User, socket.assigns.current_user)
        [from, to] = String.to_atom(current_user.settings["dashboardPeriod"])
        |> Dashboard.get_current_period
        |> Dashboard.daily
        [_, project_ids] = Dashboard.allowed_projects(current_user)
        result = case params do
            ["daily"] -> Dashboard.consolidated_chart(:daily, from, to, project_ids)
            ["monthly"] -> Dashboard.consolidated_chart(:monthly, project_ids)
            ["daily", project_id] ->
                if !Permissions.has(current_user.permissions, "dashboard_index", project_id) do
                    {:error, "No permission"}
                else
                    Dashboard.consolidated_chart(:daily, from, to, project_id)
                end
            ["monthly", project_id] ->
                if !Permissions.has(current_user.permissions, "dashboard_index", project_id) do
                    {:error, "No permission"}
                else
                    Dashboard.consolidated_chart(:monthly, project_id)
                end
        end
        response = case result do
            {:error, reason} -> {:error, %{reason: reason}}
            _ -> {:ok, result}
        end
        {:reply, response, socket}
    end
end
