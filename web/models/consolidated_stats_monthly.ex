defmodule Gt.Model.ConsolidatedStatsMonthly do
    use Gt.Web, :model
    alias Gt.Manager.Date, as: GtDate

    @collection "consolidated_stats_monthly"

    schema @collection do
        field :month, :string
        field :paymentsAmount, :integer
        field :paymentsNumber, :integer
        field :depositsAmount, :integer
        field :depositsNumber, :integer
        field :cashoutsAmount, :integer
        field :cashoutsNumber, :integer
        field :depositorsNumber, :integer
        field :firstDepositorsNumber, :integer
        field :firstDepositsAmount, :integer
        field :signupsNumber, :integer
        field :averageDeposit, Ecto.Type.FloatInt
        field :averageArpu, Ecto.Type.FloatInt
        field :averageFirstDeposit, Ecto.Type.FloatInt
        field :netgamingAmount, :integer
        field :betsAmount, :float
        field :winsAmount, :float
        field :betsNumber, :integer
        field :winsNumber, :integer
        field :rakeAmount, :integer
        field :transactorsNumber, :integer
        field :authorizationsNumber, :integer
        field :trafficSources, :map
        field :vipLevels, :map
        field :firstDepositorsNumberToSignupsNumber, Ecto.Type.FloatInt

        field :project, :binary_id
    end

    @required_fields ~w(month project)
    @optional_fields ~w(
        paymentsAmount
        paymentsNumber
        depositsAmount
        depositsNumber
        cashoutsAmount
        cashoutsNumber
        depositorsNumber
        firstDepositorsNumber
        firstDepositsAmount
        signupsNumber
        averageDeposit
        averageArpu
        averageFirstDeposit
        netgamingAmount
        betsAmount
        winsAmount
        betsNumber
        winsNumber
        rakeAmount
        transactorsNumber
        authorizationsNumber
        trafficSources
    )

    def changeset(model, params \\ :empty) do
        model
        |> cast(params, @required_fields, @optional_fields)
    end

    def months(query, months) do
        from csm in query,
        where: csm.month in ^months
    end

    def project_ids(query, project_ids) do
        from csm in query,
        where: csm.project in ^project_ids
    end

    def project_id(query, project_id) do
        from cs in query,
        where: cs.project == ^project_id
    end

    def period(query, from, to) do
        from cs in query,
        where: cs.month >= ^from and cs.month <= ^to,
        order_by: cs.month
    end

    def dashboard_charts(query) do
        from cs in query,
        select: %{
            month: cs.month,
            paymentsAmount: cs.paymentsAmount,
            depositsAmount: cs.depositsAmount,
            cashoutsAmount: cs.cashoutsAmount,
            netgamingAmount: cs.netgamingAmount,
            rakeAmount: cs.rakeAmount,
            betsAmount: cs.betsAmount,
            winsAmount: cs.winsAmount
        }
    end

    def consolidated_chart(query) do
        from cs in query,
        select: %{
            month: cs.month,
            averageDeposit: cs.averageDeposit,
            averageArpu: cs.averageArpu,
            averageFirstDeposit: cs.averageFirstDeposit,
            depositsNumber: cs.depositsNumber,
            depositorsNumber: cs.depositorsNumber,
            firstDepositorsNumber: cs.firstDepositorsNumber,
            signupsNumber: cs.signupsNumber,
            firstDepositsAmount: cs.firstDepositsAmount,
            authorizationsNumber: cs.authorizationsNumber
        }
    end
    def consolidated_chart(from, to, project_ids) do
        Mongo.aggregate(Gt.Repo.__mongo_pool__, @collection, [
            %{"$match" => %{
                "month" => %{
                    "$gte" => GtDate.format(from, :month),
                    "$lte" => GtDate.format(to, :month)
                },
                "project" => %{"$in" => project_ids}
            }},
            %{"$group" => %{
                "_id" => "$month",
                "paymentsAmount" => %{"$sum" => "$paymentsAmount"},
                "transactorsNumber" => %{"$sum" => "$transactorsNumber"},
                "depositsAmount" => %{"$sum" => "$depositsAmount"},
                "depositsNumber" => %{"$sum" => "$depositsNumber"},
                "firstDepositsAmount" => %{"$sum" => "$firstDepositsAmount"},
                "firstDepositorsNumber" => %{"$sum" => "$firstDepositorsNumber"},
                "depositorsNumber" => %{"$sum" => "$depositorsNumber"},
                "signupsNumber" => %{"$sum" => "$signupsNumber"},
                "authorizationsNumber" => %{"$sum" => "$authorizationsNumber"},
                "transactorsNumber" => %{"$sum" => "$transactorsNumber"}
            }},
            %{"$project" => %{
                "month" => "$_id",
                "averageDeposit" => %{
                    "$cond" => [
                        %{"$eq" => ["$depositsNumber", 0]},
                        0,
                        %{"$divide" => ["$depositsAmount", "$depositsNumber"]}
                    ]
                },
                "averageArpu" => %{
                    "$cond" => [
                        %{"$eq" => ["$transactorsNumber", 0]},
                        0,
                        %{"$divide" => ["$paymentsAmount", "$transactorsNumber"]}
                    ]
                },
                "averageFirstDeposit" => %{
                    "$cond" => [
                        %{"$eq" => ["$firstDepositorsNumber", 0]},
                        0,
                        %{"$divide" => ["$firstDepositsAmount", "$firstDepositorsNumber"]}
                    ]
                },
                "depositsNumber" => 1,
                "depositorsNumber" => 1,
                "firstDepositorsNumber" => 1,
                "signupsNumber" => 1,
                "firstDepositsAmount" => 1,
                "authorizationsNumber" => 1
            }}
        ])
    end

    def delete_months_project_ids(months, project_ids) do
        Mongo.delete_many(Gt.Repo.__mongo_pool__, @collection, %{
            "month" => %{"$in" => months},
            "project" => %{"$in" => project_ids}
        })
    end

    def dashboard_charts_period(from, to, project_ids) do
        Mongo.aggregate(Gt.Repo.__mongo_pool__, @collection, [
            %{"$match" => %{
                "month" => %{
                    "$gte" => GtDate.format(from, :month),
                    "$lte" => GtDate.format(to, :month)
                },
                "project" => %{"$in" => project_ids}
            }},
            %{"$group" => %{
                "_id" => "$month",
                "paymentsAmount" => %{"$sum" => "$paymentsAmount"},
                "depositsAmount" => %{"$sum" => "$depositsAmount"},
                "cashoutsAmount" => %{"$sum" => "$cashoutsAmount"},
                "netgamingAmount" => %{"$sum" => "$netgamingAmount"},
                "rakeAmount" => %{"$sum" => "$rakeAmount"},
                "betsAmount" => %{"$sum" => "$betsAmount"},
                "winsAmount" => %{"$sum" => "$winsAmount"}
            }},
            %{"$project" => %{
                "_id" => 1,
                "month" => "$_id",
                "paymentsAmount" => 1,
                "depositsAmount" => 1,
                "cashoutsAmount" => 1,
                "netgamingAmount" => %{"$add" => ["$netgamingAmount", "$rakeAmount"]},
                "rakeAmount" => "$rakeAmount",
                "betsAmount" => 1,
                "winsAmount" => 1
            }},
            %{
                "$sort" => %{"_id" => 1}
            }
        ])
    end
end
