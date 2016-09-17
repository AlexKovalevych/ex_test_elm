defmodule Gt.Manager.Dashboard do
    use Timex
    alias Gt.Manager.Date, as: GtDate
    alias Gt.Model.Payment
    alias Gt.Model.ConsolidatedStats
    alias Gt.Model.ConsolidatedStatsMonthly
    alias Gt.Repo
    alias Gt.Manager.Permissions
    alias Gt.Model.Project

    @spec daily([Timex.datetime]) :: [String.t]
    def daily([from, to]) do
        [GtDate.format(from, :date), GtDate.format(to, :date)]
    end

    @spec daily([Timex.datetime]) :: [String.t]
    def monthly([from, to]) do
        [GtDate.format(from, :month), GtDate.format(to, :month)]
    end

    def allowed_projects(user) do
        settings = user.settings
        ids = Permissions.get(user.permissions, "dashboard_index")
        projects = Project
        |> Project.ids(ids)
        |> Repo.all
        ids = Enum.reduce(projects, [], fn (project, acc) ->
            if !Enum.member?(ids, project.id) do
                acc
            else
                cond do
                    settings["dashboardProjectsType"] == "partner" && project.isPartner -> acc ++ [project.id]
                    settings["dashboardProjectsType"] == "default" && !project.isPartner -> acc ++ [project.id]
                    true -> acc
                end
            end
        end)
        |> Enum.map(fn id ->
            {:ok, object_id} = Mongo.Ecto.ObjectID.dump(id)
            object_id
        end)
        [projects, ids]
    end

    def load_data(user, period \\ nil) do
        settings = user.settings
        [projects, project_ids] = allowed_projects(user)
        period = case period do
            nil -> String.to_atom(settings["dashboardPeriod"])
            _ -> String.to_atom(period)
        end
        data = get_stats(
            period,
            settings["dashboardComparePeriod"],
            project_ids
        )
        charts = get_charts(period, project_ids)
        %{
            stats: data.stats,
            charts: charts,
            periods: data.periods,
            totals: data.totals,
            projects: projects,
            activeTab: 0
        }
    end

    def get_current_period(:month) do
        now = GtDate.today
        current_start = now |> Date.set([day: 1])
        [current_start, now]
    end
    def get_current_period(:year) do
        now = GtDate.today
        current_start = now |> Date.set([month: 1, day: 1])
        [current_start, now]
    end
    def get_current_period(:days30) do
        now = GtDate.today
        current_start = now |> Timex.shift(days: -30)
        [current_start, now]
    end
    def get_current_period(:months12) do
        current_end = GtDate.today |> Date.set([day: 1])
        current_start = current_end |> Timex.shift(months: -11)
        [current_start, current_end]
    end

    def get_period(:month, previous_period) do
        now = GtDate.today
        current_start = now |> Date.set([day: 1])
        comparison_start = Timex.shift(current_start, months: previous_period)
        comparison_end = now |> Timex.shift(months: previous_period)
        current_period = [GtDate.format(current_start, :date), GtDate.format(now, :date)]
        comparison_period = [GtDate.format(comparison_start, :date), GtDate.format(comparison_end, :date)]
        [current_start, now, comparison_start, comparison_end, current_period, comparison_period]
    end
    def get_period(:year) do
        now = GtDate.today
        current_start = now |> Date.set([month: 1, day: 1])
        current_end = now
        comparison_start = Timex.shift(current_start, years: -1)
        comparison_end = now |> Timex.shift(years: -1)
        current_period = [GtDate.format(current_start, :date), GtDate.format(current_end, :date)]
        comparison_period = [GtDate.format(comparison_start, :date), GtDate.format(comparison_end, :date)]
        [current_start, current_end, comparison_start, comparison_end, current_period, comparison_period]
    end
    def get_period(:days30) do
        now = GtDate.today
        current_start = now |> Timex.shift(days: -30)
        comparison_end = current_start |> Timex.shift(days: -1)
        comparison_start = comparison_end |> Timex.shift(days: -30)
        current_period = [GtDate.format(current_start, :date), GtDate.format(now, :date)]
        comparison_period = [GtDate.format(comparison_start, :date), GtDate.format(comparison_end, :date)]
        [current_start, now, comparison_start, comparison_end, current_period, comparison_period]
    end
    def get_period(:months12) do
        now = GtDate.today
        current_end = now |> Date.set([day: 1])
        current_start = current_end |> Timex.shift(months: -11)
        comparison_end = current_start |> Timex.shift(months: -1)
        comparison_start = comparison_end |> Timex.shift(days: -11)
        current_period = [GtDate.format(current_start, :date), GtDate.format(now, :date)]
        comparison_period = [GtDate.format(comparison_start, :date), GtDate.format(comparison_end, :date)]
        [current_start, now, comparison_start, comparison_end, current_period, comparison_period]
    end

    def get_stats([current_start, current_end, comparison_start, comparison_end, current_period, comparison_period], project_ids) do
        # calculate project stats
        initial = %{
            "current" => %{
                "authorizationsNumber" => 0,
                "averageArpu" => 0,
                "averageDeposit" => 0,
                "averageFirstDeposit" => 0,
                "betsAmount" => 0,
                "cashoutsAmount" => 0,
                "cashoutsNumber" => 0,
                "depositorsNumber" => 0,
                "depositsAmount" => 0,
                "depositsNumber" => 0,
                "firstDepositorsNumber" => 0,
                "firstDepositsAmount" => 0,
                "netgamingAmount" => 0,
                "paymentsAmount" => 0,
                "paymentsNumber" => 0,
                "rakeAmount" => 0,
                "signupsNumber" => 0,
                "winsAmount" => 0
            },
            "comparison" => %{
                "authorizationsNumber" => 0,
                "averageArpu" => 0,
                "averageDeposit" => 0,
                "averageFirstDeposit" => 0,
                "betsAmount" => 0,
                "cashoutsAmount" => 0,
                "cashoutsNumber" => 0,
                "depositorsNumber" => 0,
                "depositsAmount" => 0,
                "depositsNumber" => 0,
                "firstDepositorsNumber" => 0,
                "firstDepositsAmount" => 0,
                "netgamingAmount" => 0,
                "paymentsAmount" => 0,
                "paymentsNumber" => 0,
                "rakeAmount" => 0,
                "signupsNumber" => 0,
                "winsAmount" => 0
            }
        }
        stats = Enum.into(project_ids, %{}, fn id ->
            {Gt.Model.id_to_string(id), initial}
        end)
        stats = Payment.depositors_number_by_period(
            current_start,
            current_end,
            project_ids
        )
        |> Enum.to_list
        |> set_depositors(stats, "current")
        stats = Payment.depositors_number_by_period(
            comparison_start,
            comparison_end,
            project_ids
        )
        |> Enum.to_list
        |> set_depositors(stats, "comparison")

        stats = ConsolidatedStats.dashboard(current_start, current_end, project_ids)
        |> Enum.to_list
        |> set_stats(stats, "current")

        stats = ConsolidatedStats.dashboard(comparison_start, comparison_end, project_ids)
        |> Enum.to_list
        |> set_stats(stats, "comparison")

        # calculate totals
        totals = initial
        totals = Payment.depositors_number_by_period(
            current_start,
            current_end,
            project_ids,
            :total
        )
        |> Enum.to_list
        |> set_depositors(totals, "current", :total)

        totals = Payment.depositors_number_by_period(
            comparison_start,
            comparison_end,
            project_ids,
            :total
        )
        |> Enum.to_list
        |> set_depositors(totals, "comparison", :total)

        totals = ConsolidatedStats.dashboard(current_start, current_end, project_ids, :total)
        |> Enum.to_list
        |> set_stats(totals, "current", :total)

        totals = ConsolidatedStats.dashboard(comparison_start, comparison_end, project_ids, :total)
        |> Enum.to_list
        |> set_stats(totals, "comparison", :total)

        %{
            stats: Enum.map(stats, fn {id, values} -> %{id: id, values: Map.values(values)} end),
            periods: %{current: current_period, comparison: comparison_period},
            totals: totals
        }

    end
    def get_stats(:month, previous_period, project_ids) do
        get_stats(get_period(:month, previous_period), project_ids)
    end
    def get_stats(:year, _, project_ids) do
        get_stats(get_period(:year), project_ids)
    end
    def get_stats(:days30, _, project_ids) do
        get_stats(get_period(:days30), project_ids)
    end
    def get_stats(:months12, _, project_ids) do
        get_stats(get_period(:months12), project_ids)
    end

    def get_charts([daily_from, daily_to], [monthly_from, monthly_to], project_ids) do
        daily_charts = Enum.reduce(project_ids, [], fn (project_id, acc) ->
            id = Gt.Model.id_to_string(project_id)
            data = ConsolidatedStats
            |> ConsolidatedStats.dashboard_charts
            |> ConsolidatedStats.project_id(id)
            |> ConsolidatedStats.period(daily_from, daily_to)
            |> Repo.all
            |> Enum.reduce([], fn (daily_stat, acc) ->
                acc ++ [daily_stat]
            end)
            acc ++ [%{project: id, values: data}]
        end)

        monthly_charts = Enum.reduce(project_ids, [], fn (project_id, acc) ->
            id = Gt.Model.id_to_string(project_id)
            data = ConsolidatedStatsMonthly
            |> ConsolidatedStatsMonthly.dashboard_charts
            |> ConsolidatedStatsMonthly.project_id(id)
            |> ConsolidatedStatsMonthly.period(monthly_from, monthly_to)
            |> Repo.all
            |> Enum.reduce([], fn (monthly_stat, acc) ->
                acc ++ [monthly_stat]
            end)
            acc ++ [%{project: id, values: data}]
        end)

        total_daily_charts = ConsolidatedStats.dashboard_charts_period(daily_from, daily_to, project_ids)
        |> Enum.reduce([], fn (daily_stat, acc) ->
            acc ++ [daily_stat]
        end)

        total_monthly_charts = ConsolidatedStatsMonthly.dashboard_charts_period(monthly_from, monthly_to, project_ids)
        |> Enum.reduce([], fn (monthly_stat, acc) ->
            acc ++ [monthly_stat]
        end)

        %{
            stats: %{
                daily: daily_charts,
                monthly: monthly_charts
            },
            totals: %{
                daily: total_daily_charts,
                monthly: total_monthly_charts
            }
        }
    end
    def get_charts(:month, project_ids) do
        get_charts(daily(get_current_period(:month)), daily(get_current_period(:months12)), project_ids)
    end
    def get_charts(:year, project_ids) do
        get_charts(daily(get_current_period(:year)), daily(get_current_period(:months12)), project_ids)
    end
    def get_charts(:days30, project_ids) do
        get_charts(daily(get_current_period(:days30)), daily(get_current_period(:months12)), project_ids)
    end
    def get_charts(:months12, project_ids) do
        get_charts(daily(get_current_period(:months12)), daily(get_current_period(:months12)), project_ids)
    end

    def consolidated_chart(:daily, from, to, project_ids) when is_list(project_ids) do
        ConsolidatedStats.consolidated_chart(from, to, project_ids)
        |> Enum.to_list
        |> Enum.chunk(1)
        |> Enum.into(%{}, fn [consolidated_stats] ->
            {Map.get(consolidated_stats, "date"), consolidated_stats}
        end)
    end
    def consolidated_chart(:daily, from, to, project_id) do
        ConsolidatedStats
        |> ConsolidatedStats.project_id(project_id)
        |> ConsolidatedStats.period(from, to)
        |> ConsolidatedStats.consolidated_chart
        |> Repo.all
        |> Enum.chunk(1)
        |> Enum.into(%{}, fn [consolidated_stats] ->
            {consolidated_stats.date, consolidated_stats}
        end)
    end
    def consolidated_chart(:monthly, project_ids) when is_list(project_ids) do
        [from, to] = monthly(get_current_period(:months12))
        ConsolidatedStatsMonthly.consolidated_chart(from, to, project_ids)
        |> Enum.to_list
        |> Enum.chunk(1)
        |> Enum.into(%{}, fn [consolidated_stats] ->
            {Map.get(consolidated_stats, "month"), consolidated_stats}
        end)
    end
    def consolidated_chart(:monthly, project_id) do
        [from, to] = monthly(get_current_period(:months12))
        ConsolidatedStatsMonthly
        |> ConsolidatedStatsMonthly.project_id(project_id)
        |> ConsolidatedStatsMonthly.period(from, to)
        |> ConsolidatedStatsMonthly.consolidated_chart
        |> Repo.all
        |> Enum.chunk(1)
        |> Enum.into(%{}, fn [consolidated_stats] ->
            {consolidated_stats.month, consolidated_stats}
        end)
    end

    defp set_depositors(data, stats, key) do
        Enum.reduce(data, stats, fn (project_stats, acc) ->
            depositorsNumber = if project_stats["depositorsNumber"] do
                project_stats["depositorsNumber"]
            else
                0
            end
            put_in(acc, [Gt.Model.id_to_string(project_stats["_id"]), key, "depositorsNumber"], depositorsNumber)
        end)
    end
    defp set_depositors(data, totals, key, :total) do
        depositorsNumber = if Enum.at(data, 0)["depositorsNumber"] do
            Enum.at(data, 0)["depositorsNumber"]
        else
            0
        end
        put_in(totals, [key, "depositorsNumber"], depositorsNumber)
    end

    defp set_stats([], stats, _) do
        stats
    end
    defp set_stats(data, stats, key) do
        Enum.reduce(data, stats, fn (project_stats, acc) ->
            project_id = Gt.Model.id_to_string(project_stats["_id"])
            metrics_stats = Map.drop(project_stats, ["_id"])
            project_period_stats = get_in(stats, [project_id, key])
            put_in(acc, [project_id, key], Map.merge(project_period_stats, metrics_stats))
        end)
    end
    defp set_stats([], stats, _, :total) do
        stats
    end
    defp set_stats(data, totals, key, :total) do
        metrics_stats = Map.drop(Enum.at(data, 0), ["_id"])
        total_period_stats = get_in(totals, [key])
        put_in(totals, [key], Map.merge(total_period_stats, metrics_stats))
    end
end
