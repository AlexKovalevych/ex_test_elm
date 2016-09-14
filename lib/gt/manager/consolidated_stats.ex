defmodule Gt.Manager.ConsolidatedStats do
    require Logger
    alias Gt.Model.{
        Payment,
        ProjectUser,
        ProjectUserGame,
        PokerGame,
        ProcessedEvent,
        ConsolidatedStats,
        ConsolidatedStatsMonthly
    }
    alias Gt.Manager.Date, as: GtDate
    alias Gt.Repo
    use Timex

    defmacrop process_data(name, term) do
        quote do
            message = unquote name
            Logger.info "Aggregating #{message}"
            data = unquote(term) |> Enum.to_list
            Logger.info "Updating dashboard #{message}"
            total = length(data)
            ParallelStream.each(1..total, fn i ->
                project_day = Enum.at(data, i - 1)
                ConsolidatedStats.upsert_project_date(project_day["_id"], Map.drop(project_day, ["_id"]))
                if i != total do
                    ProgressBar.render(i, total)
                end
            end) |> Enum.to_list
            ProgressBar.render(total, total)
        end
    end

    @spec update_daily_stats(String.t, String.t, [Mongo.Ecto.ObjectID]) :: Atom
    def update_daily_stats(from, to, project_ids) do
        Logger.configure([level: :info])
        process_data("payments", Payment.dashboard_stats(from, to, project_ids))
        process_data("first deposits", ProjectUser.first_deposit_stats(from, to, project_ids))
        process_data("signups", ProjectUser.signup_stats(from, to, project_ids))
        process_data("netgaming", ProjectUserGame.netgaming(from, to, project_ids))
        process_data("rake", PokerGame.rake(from, to, project_ids))
        process_data("authorizations", ProcessedEvent.authorizations_by_period(from, to, project_ids))
    end

    @spec update_monthly_stats(String.t, String.t, [Mongo.Ecto.ObjectID]) :: Atom
    def update_monthly_stats(from, to, project_ids) do
        Logger.info "Aggregating monthly stats"
        diff = GtDate.diff(from, to, :months)
        interval = Interval.new(from: from, until: [months: diff], step: [months: 1], right_open: false)
        periods = Enum.map(interval, fn month ->
            from = month
            last_date = Timex.Calendar.Gregorian.days_in_month(from.year, from.month)
            to = from |> DateTime.set([{:date, {from.year, from.month, last_date}}])
            {from, to}
        end)
        months = Enum.map(interval, fn datetime ->
            GtDate.format(datetime, :month)
        end)
        ConsolidatedStatsMonthly.delete_months_project_ids(months, project_ids)
        total = Enum.count(periods)
        Enum.map(1..total, fn i ->
            {from, to} = Enum.at(periods, i - 1)
            stats = ConsolidatedStats.monthly_by_interval(from, to)
            ParallelStream.map(stats, fn monthly_stats ->
                project_id = monthly_stats["_id"]
                vip_levels = ProjectUser.vip_levels_by_month(from, to, project_id) |> Enum.to_list
                vip_levels = case Enum.count(vip_levels) > 0 do
                    true -> Enum.at(vip_levels, 0)
                    false -> %{}
                end
                unique_depositors = Payment.depositors_number_by_period(from, to, project_id) |> Enum.to_list
                unique_depositors = case Enum.count(unique_depositors) > 0 do
                    true -> Enum.at(unique_depositors, 0) |> Map.get("depositorsNumber")
                    false -> 0
                end
                transactors_number = Payment.transactors_number_by_period(from, to, project_id) |> Enum.to_list
                transactors_number = case Enum.count(transactors_number) > 0 do
                    true -> Enum.at(transactors_number, 0) |> Map.get("transactorsNumber")
                    false -> 0
                end
                stats = monthly_stats["months"] |> Enum.at(0)
                average_arpu = case transactors_number do
                    0 -> 0
                    _ -> stats["paymentsAmount"] / transactors_number
                end
                first_depositors_number_to_signups_number = case stats["signupsNumber"] do
                    0 -> 0
                    _ -> stats["firstDepositorsNumber"] / stats["signupsNumber"]
                end
                Repo.insert!(ConsolidatedStatsMonthly.changeset(%ConsolidatedStatsMonthly{}, %{
                    project: Base.encode16(project_id.value, case: :lower),
                    month: GtDate.format(from, :month),
                    vipLevels: vip_levels,
                    depositorsNumber: unique_depositors,
                    transactorsNumber: transactors_number,
                    paymentsAmount: stats["paymentsAmount"],
                    paymentsNumber: stats["paymentsNumber"],
                    depositsAmount: stats["depositsAmount"],
                    depositsNumber: stats["depositsNumber"],
                    cashoutsAmount: stats["cashoutsAmount"],
                    cashoutsNumber: stats["cashoutsNumber"],
                    averagePayment: stats["averagePayment"],
                    averageArpu: average_arpu,
                    averageDeposit: stats["averageDeposit"],
                    averageFirstDeposit: stats["averageFirstDeposit"],
                    firstDepositorsNumber: stats["firstDepositorsNumber"],
                    firstDepositsAmount: stats["firstDepositsAmount"],
                    signupsNumber: stats["signupsNumber"],
                    netgamingAmount: stats["netgamingAmount"],
                    betsAmount: stats["betsAmount"],
                    winsAmount: stats["winsAmount"],
                    rakeAmount: stats["rakeAmount"],
                    firstDepositorsNumberToSignupsNumber: first_depositors_number_to_signups_number,
                    authorizationsNumber: stats["authorizationsNumber"]
                }))
            end) |> Enum.to_list
            ProgressBar.render(i, total)
        end)
    end
end
