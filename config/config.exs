# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :gt, Gt.Endpoint,
    url: [host: "localhost"],
    root: Path.dirname(__DIR__),
    secret_key_base: "A4N0BdJAieRAntLI9bKdNX/7Lv1hvBr4Pdp4QMOBdHjlVkjLAPH9NwKc5jKGYbA+",
    render_errors: [accepts: ~w(html json)],
    pubsub: [name: Gt.PubSub,
            adapter: Phoenix.PubSub.PG2],
    http: [compress: true]

config :gt,
    permissions: %{
        "dashboard" => %{
            "dashboard_index" => []
        },
        "finance" => %{
            "payments_check" => [],
            "payment_systems" => [],
            "incoming_reports" => [],
            "funds_flow" => [],
            "monthly_balance" => []
        },
        "statistics" => %{
            "consolidated_report" => [],
            "ltv_report" => [],
            "segments_report" => [],
            "retention" => [],
            "activity_waves" => [],
            "timeline_report" => [],
            "cohorts_report" => []
        },
        "calendar_events" => %{
            "events_list" => [],
            "events_types_list" => [],
            "events_groups_list" => []
        },
        "players" => %{
            "multiaccounts" => [],
            "signup_channels" => []
        }
    },
    admin_permissions: [
        "users",
        "projects",
        "notifications",
        "permissions",
        "data_sources",
        "smtp_servers"
    ],
    amqp: [
        connections: [
            default: "amqp://guest:guest@localhost"
        ],
        producers: [
            iqsms: %{
                connection: :default,
                exchange: "reactions",
                queue: "send_sms_iqsms",
                routing: "sms.iqsms",
                sender: "iqsms"
            }
        ]
    ]

# Configures Elixir's Logger
config :logger, :console,
    format: "$time $metadata[$level] $message\n",
    metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
    migration: true,
    binary_id: false

config :guardian, Guardian,
    issuer: "Gt.#{Mix.env}",
    ttl: { 10, :days },
    secret_key: to_string(Mix.env),
    serializer: Gt.GuardianSerializer,
    hooks: Gt.GuardianDb

config :porcelain, :driver, Porcelain.Driver.Basic

config :gt, Gt.ElmIo,
    pool_size: 20, # default 5
    max_overflow: 10, # default 10
    script: Path.join([__DIR__, "../node_modules/elm-stdio/bin/elm-stdio"]),
    watch_files: [Path.join(__DIR__, "../priv/server/js/app.js") |> Path.expand]
