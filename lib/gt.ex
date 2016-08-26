defmodule Gt do
    use Application

    # See http://elixir-lang.org/docs/stable/elixir/Application.html
    # for more information on OTP Applications
    def start(_type, _args) do
        import Supervisor.Spec, warn: false

        children = [
            # Start the endpoint when the application starts
            supervisor(Gt.Endpoint, []),
            # Start the Ecto repository
            supervisor(Gt.Repo, []),
            # Here you could define other workers and supervisors as children
            # worker(Gt.Worker, [arg1, arg2, arg3]),
            supervisor(Gt.ElmIo, []),
            worker(Gt.Amqp.Connections.Default, [[], [name: GtAmqpDefault]])
        ]

        # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
        # for other strategies and supported options
        opts = [strategy: :one_for_one, name: Gt.Supervisor]
        Supervisor.start_link(children, opts)
    end

    def start_repo_supervisor do
        import Supervisor.Spec, warn: false
        opts = [strategy: :one_for_one, name: Gt.Supervisor]
        Supervisor.start_link([supervisor(Gt.Repo, [])], opts)
    end

    # Tell Phoenix to update the endpoint configuration
    # whenever the application is updated.
    def config_change(changed, _new, removed) do
        Gt.Endpoint.config_change(changed, removed)
        :ok
    end
end
