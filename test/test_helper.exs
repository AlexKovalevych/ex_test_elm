ExUnit.start

ExUnit.configure(exclude: [:unit, :functional])

# Mix.Task.run "ecto.create", ~w(-r Gt.Repo --quiet)
# Mix.Task.run "ecto.migrate", ~w(-r Gt.Repo --quiet)
# Ecto.Adapters.SQL.begin_test_transaction(Gt.Repo)
