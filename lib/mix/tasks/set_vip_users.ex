defmodule Mix.Tasks.Gt.SetVipUsers do
    use Gt.Task
    alias Gt.Manager.Date, as: GtDate
    alias Gt.Model.{ProjectUser}
    alias Gt.Repo

    @shortdoc "Set vip users"

    @moduledoc """
        This is where we would put any long form documentation or doctests.
    """

    def title, do: @shortdoc

    def parse_args(_), do: :ok

    def do_process(_) do
        project_users = ProjectUser.vip_levels
        total = Enum.count(project_users)

        Enum.reduce(project_users, 1, fn (project_user, i) ->
            stat = Enum.sort(project_user["stat"])
            vip_levels = Enum.reduce(
                stat,
                [0, %{}],
                fn ({k, v}, acc) ->
                    cond do
                        k == "total" || !get_in(v, ["dep", "cash_real"]) || String.length(k) == 5 -> acc
                        true ->
                            deposits = Enum.at(acc, 0) + get_in(v, ["dep", "cash_real"])
                            acc = List.replace_at(acc, 0, deposits)
                            vip = Enum.at(acc, 1)
                            vip = Enum.reduce(ProjectUser.vip_level_options, vip, fn (vip_level, acc) ->
                                cond do
                                    deposits >= vip_level * 100 ->
                                        date = GtDate.convert(k, :stat_day, :date)
                                        Map.put_new(acc, to_string(vip_level), date)
                                    true -> acc
                                end
                            end)
                            List.replace_at(acc, 1, vip)
                    end
                end
            )
            Mongo.update_one(
                Repo.__mongo_pool__,
                ProjectUser.collection,
                %{"_id" => project_user["_id"]},
                %{"$set" => %{"vipLevel" => Enum.at(vip_levels, 1)}}
            )
            ProgressBar.render(i, total)
            i + 1
        end)
    end
end
