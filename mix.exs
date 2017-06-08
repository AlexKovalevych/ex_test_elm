defmodule Gt.Mixfile do
    use Mix.Project

    def project do
        [app: :gt,
         version: "0.0.1",
         elixir: "~> 1.0",
         elixirc_paths: elixirc_paths(Mix.env),
         compilers: [:phoenix, :gettext] ++ Mix.compilers,
         build_embedded: Mix.env == :prod,
         start_permanent: Mix.env == :prod,
         aliases: aliases(),
         deps: deps(),
         test_coverage: [tool: ExCoveralls],
         preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]]
    end

    # Configuration for the OTP application.
    #
    # Type `mix help compile.app` for more information.
    def application do
        [mod: {Gt, []},
         applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext,
                        :phoenix_ecto, :mongodb_ecto, :std_json_io, :guardian, :comeonin,
                        :timex, :amqp]]
    end

    # Specifies which paths to compile per environment.
    defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
    defp elixirc_paths(_),     do: ["lib", "web"]

    # Specifies your project dependencies.
    #
    # Type `mix help deps` for examples and options.
    defp deps do
        [
            {:phoenix, "~> 1.1.6"},
            {:phoenix_ecto, "~> 1.2.0"},
            {:phoenix_html, "~> 2.4"},
            {:phoenix_live_reload, "~> 1.0", only: :dev},
            {:gettext, "~> 0.9"},
            {:cowboy, "~> 1.0"},
            {:mongodb_ecto, "~> 0.1.4"},
            {:std_json_io, git: "https://github.com/AlexKovalevych/std_json_io.git", branch: "fix-large-output"},
            {:comeonin, "~> 2.4"},
            {:guardian, "~> 0.12.0"},
            {:excoveralls, "~> 0.5.5"},
            {:timex, "~> 2.2"},
            {:tzdata, "~> 0.1.8", override: true},
            {:exprintf, "~> 0.1.6"},
            {:progress_bar, "~> 1.5"},
            {:parallel_stream, "~> 1.0"},
            {:amqp, "~> 0.1.4"},
            {:amqp_client, git: "https://github.com/dsrosario/amqp_client.git", branch: "erlang_otp_19", override: true},
            {:pot, "~>0.9.5"}
            # {:nio_google_authenticator, "~> 1.0.1"} Required newer ecto
        ]
    end

    # Aliases are shortcut or tasks specific to the current project.
    # For example, to create, migrate and run the seeds file at once:
    #
    #     $ mix ecto.setup
    #
    # See the documentation for `Mix` for more info on aliases.
    defp aliases do
        [
            "ecto.setup": [
                "ecto.create",
                "ecto.migrate",
                "run priv/repo/seeds.exs",
                "gt.app_cache --from 2013-01-01",
                "gt.set_users_stat",
                "gt.set_vip_users"
            ],
            "ecto.reset": [
                "ecto.drop",
                "ecto.setup"
            ],
            "prod": [
                "compile --only PROD",
                "phoenix.digest"
            ]
        ]
    end
end
