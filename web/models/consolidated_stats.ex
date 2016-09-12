defmodule Gt.Model.ConsolidatedStats do
    use Gt.Web, :model
    alias Gt.Manager.Date, as: GtDate

    @collection "consolidated_stats"

    schema @collection do
        field :date, :string
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
        field :betsAmount, :integer
        field :winsAmount, :integer
        field :betsNumber, :integer
        field :winsNumber, :integer
        field :rakeAmount, :integer
        field :transactorsNumber, :integer
        field :authorizationsNumber, :integer
        field :trafficSources, :map

        field :project, :binary_id
    end

    @required_fields ~w(date project)
    @optional_fields ~w(paymentsAmount
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

    def upsert_project_date(%{"date" => date, "project" => project_id}, stats) do
        Mongo.update_one(
            Gt.Repo.__mongo_pool__,
            @collection,
            %{
                "project" => project_id,
                "date" => date
            },
            %{
                "$set" => stats
            },
            [{:upsert, true}]
        )
    end

    def monthly_by_interval(from, to) do
        Mongo.aggregate(Gt.Repo.__mongo_pool__, @collection, [
            %{"$match" => %{
                "date" => %{
                    "$gte" => GtDate.format(from, :date),
                    "$lte" => GtDate.format(to, :date)
                }
            }},
            %{"$group" => %{
                "_id" => %{
                    "project" => "$project",
                    "month" => %{"$substr" => ["$date", 0, 7]},
                },
                "paymentsAmount" => %{"$sum" => "$paymentsAmount"},
                "paymentsNumber" => %{"$sum" => "$paymentsNumber"},
                "depositsAmount" => %{"$sum" => "$depositsAmount"},
                "cashoutsAmount" => %{"$sum" => "$cashoutsAmount"},
                "cashoutsNumber" => %{"$sum" => "$cashoutsNumber"},
                "depositsNumber" => %{"$sum" => "$depositsNumber"},
                "firstDepositorsNumber" => %{"$sum" => "$firstDepositorsNumber"},
                "firstDepositsAmount" => %{"$sum" => "$firstDepositsAmount"},
                "signupsNumber" => %{"$sum" => "$signupsNumber"},
                "netgamingAmount" => %{"$sum" => "$netgamingAmount"},
                "betsAmount" => %{"$sum" => "$betsAmount"},
                "winsAmount" => %{"$sum" => "$winsAmount"},
                "rakeAmount" => %{"$sum" => "$rakeAmount"},
                "authorizationsNumber" => %{"$sum" => "$authorizationsNumber"},
            }},
            %{"$project" => %{
                "_id" => 1,
                "month" => %{
                    "month" => "$_id.month",
                    "paymentsAmount" => "$paymentsAmount",
                    "paymentsNumber" => "$paymentsNumber",
                    "depositsAmount" => "$depositsAmount",
                    "cashoutsAmount" => "$cashoutsAmount",
                    "cashoutsNumber" => "$cashoutsNumber",
                    "averagePayment" => %{
                        "$cond" => [
                            %{"$eq" => ["$paymentsNumber", 0]},
                            0,
                            %{"$divide" => ["$paymentsAmount", "$paymentsNumber"]}
                        ]
                    },
                    "averageDeposit" => %{
                        "$cond" => [
                            %{"$eq" => ["$depositsNumber", 0]},
                            0,
                            %{"$divide" => ["$depositsAmount", "$depositsNumber"]}
                        ]
                    },
                    "averageFirstDeposit" => %{
                        "$cond" => [
                            %{"$eq" => ["$firstDepositorsNumber", 0]},
                            0,
                            %{"$divide" => ["$firstDepositsAmount", "$firstDepositorsNumber"]}
                        ]
                    },
                    "depositsNumber" => "$depositsNumber",
                    "depositorsNumber" => "$depositorsNumber",
                    "firstDepositorsNumber" => "$firstDepositorsNumber",
                    "firstDepositsAmount" => "$firstDepositsAmount",
                    "signupsNumber" => "$signupsNumber",
                    "netgamingAmount" => "$netgamingAmount",
                    "betsAmount" => "$betsAmount",
                    "winsAmount" => "$winsAmount",
                    "rakeAmount" => "$rakeAmount",
                    "authorizationsNumber" => "$authorizationsNumber"
                }
            }},
            %{"$group" => %{
                "_id" => "$_id.project",
                "months" => %{"$push" => "$month"}
            }}
        ])
    end

    def dashboard(from, to, project_ids, group_by \\ :project) do
        group_id = case group_by do
            :project -> "$project"
            :total -> 1
        end
        Mongo.aggregate(Gt.Repo.__mongo_pool__, @collection, [
            %{"$match" => %{
                "date" => %{
                    "$gte" => GtDate.format(from, :date),
                    "$lte" => GtDate.format(to, :date)
                },
                "project" => %{"$in" => project_ids}
            }},
            %{"$group" => %{
                "_id" => group_id,
                "paymentsAmount" => %{"$sum" => "$paymentsAmount"},
                "paymentsNumber" => %{"$sum" => "$paymentsNumber"},
                "depositsAmount" => %{"$sum" => "$depositsAmount"},
                "cashoutsAmount" => %{"$sum" => "$cashoutsAmount"},
                "cashoutsNumber" => %{"$sum" => "$cashoutsNumber"},
                "depositsNumber" => %{"$sum" => "$depositsNumber"},
                "firstDepositorsNumber" => %{"$sum" => "$firstDepositorsNumber"},
                "firstDepositsAmount" => %{"$sum" => "$firstDepositsAmount"},
                "signupsNumber" => %{"$sum" => "$signupsNumber"},
                "netgamingAmount" => %{"$sum" => "$netgamingAmount"},
                "betsAmount" => %{"$sum" => "$betsAmount"},
                "winsAmount" => %{"$sum" => "$winsAmount"},
                "rakeAmount" => %{"$sum" => "$rakeAmount"},
                "authorizationsNumber" => %{"$sum" => "$authorizationsNumber"},
                "transactorsNumber" => %{"$sum" => "$transactorsNumber"}
            }},
            %{"$project" => %{
                "_id" => 1,
                "paymentsAmount" => "$paymentsAmount",
                "paymentsNumber" => "$paymentsNumber",
                "depositsAmount" => "$depositsAmount",
                "cashoutsAmount" => "$cashoutsAmount",
                "cashoutsNumber" => "$cashoutsNumber",
                "averageDeposit" => %{
                    "$cond" => [
                        %{"$eq" => ["$depositsNumber", 0]},
                        0,
                        %{"$divide" => ["$depositsAmount", "$depositsNumber"]}
                    ]
                },
                "averageFirstDeposit" => %{
                    "$cond" => [
                        %{"$eq" => ["$firstDepositorsNumber", 0]},
                        0,
                        %{"$divide" => ["$firstDepositsAmount", "$firstDepositorsNumber"]}
                    ]
                },
                "averageArpu" => %{
                    "$cond" => [
                        %{"$eq" => ["$transactorsNumber", 0]},
                        0,
                        %{"$divide" => ["$paymentsAmount", "$transactorsNumber"]}
                    ]
                },
                "depositsNumber" => "$depositsNumber",
                "firstDepositorsNumber" => "$firstDepositorsNumber",
                "firstDepositsAmount" => "$firstDepositsAmount",
                "signupsNumber" => "$signupsNumber",
                "netgamingAmount" => "$netgamingAmount",
                "betsAmount" => "$betsAmount",
                "winsAmount" => "$winsAmount",
                "rakeAmount" => "$rakeAmount",
                "authorizationsNumber" => "$authorizationsNumber"
            }}
        ])
    end

    def project_id(query, project_id) do
        from cs in query,
        where: cs.project == ^project_id
    end

    def period(query, from, to) do
        from cs in query,
        where: cs.date >= ^from and cs.date <= ^to,
        order_by: cs.date
    end

    def dashboard_charts(query) do
        from cs in query,
        select: %{
            date: cs.date,
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
            date: cs.date,
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
                "date" => %{
                    "$gte" => GtDate.format(from, :date),
                    "$lte" => GtDate.format(to, :date)
                },
                "project" => %{"$in" => project_ids}
            }},
            %{"$group" => %{
                "_id" => "$date",
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
                "date" => "$_id",
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

    def dashboard_charts_period(from, to, project_ids) do
        Mongo.aggregate(Gt.Repo.__mongo_pool__, @collection, [
            %{"$match" => %{
                "date" => %{
                    "$gte" => GtDate.format(from, :date),
                    "$lte" => GtDate.format(to, :date)
                },
                "project" => %{"$in" => project_ids}
            }},
            %{"$group" => %{
                "_id" => "$date",
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
                "date" => "$_id",
                "paymentsAmount" => 1,
                "depositsAmount" => 1,
                "cashoutsAmount" => 1,
                "netgamingAmount" => %{"$add" => ["$netgamingAmount", "$rakeAmount"]},
                "betsAmount" => 1,
                "winsAmount" => 1
            }},
            %{
                "$sort" => %{"_id" => 1}
            }
        ])
    end
end
