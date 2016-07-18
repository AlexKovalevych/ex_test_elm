defmodule Gt.Manager.Dashboard do
    use Timex
    alias Gt.Manager.Date, as: GtDate
    alias Gt.Model.Payment
    alias Gt.Model.ConsolidatedStats

    def get_stats(:month, previous_period, project_ids) do
        now = GtDate.today
        current_start = now |> Date.set([day: 1])
        current_end = now
        comparison_start = Timex.shift(current_start, months: previous_period)
        comparison_end = now |> Timex.shift(months: previous_period)
        current_period = [GtDate.format(current_start, :date), GtDate.format(current_end, :date)]
        comparison_period = [GtDate.format(comparison_start, :date), GtDate.format(comparison_end, :date)]

        # calculate project stats
        initial = %{
            "current" => %{},
            "comparison" => %{}
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
            stats: stats,
            periods: %{current: current_period, comparison: comparison_period},
            totals: totals
        }
    end
    def get_stats(:month_period, project_ids) do

    end
    def get_stats(:year, project_ids) do

    end
    def get_stats(:year_period, project_ids) do

    end

    defp set_depositors(data, stats, key) do
        Enum.reduce(data, stats, fn (project_stats, acc) ->
            put_in(acc, [Gt.Model.id_to_string(project_stats["_id"]), key, "depositorsNumber"], project_stats["depositorsNumber"])
        end)
    end
    defp set_depositors(data, totals, key, :total) do
        put_in(totals, [key, "depositorsNumber"], Enum.at(data, 0)["depositorsNumber"])
    end

    defp set_stats(data, stats, key) do
        Enum.reduce(data, stats, fn (project_stats, acc) ->
            project_id = Gt.Model.id_to_string(project_stats["_id"])
            metrics_stats = Map.drop(project_stats, ["_id"])
            project_period_stats = get_in(stats, [project_id, key])
            put_in(acc, [project_id, key], Map.merge(project_period_stats, metrics_stats))
        end)
    end
    defp set_stats(data, totals, key, :total) do
        metrics_stats = Map.drop(Enum.at(data, 0), ["_id"])
        total_period_stats = get_in(totals, [key])
        put_in(totals, [key], Map.merge(total_period_stats, metrics_stats))
    end
end