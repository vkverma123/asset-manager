# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :asset_manager,
  ecto_repos: [AssetManager.Repo],
  event_stores: [AssetManager.EventStore]

config :asset_manager,
  supervisor_max_restarts: 10

config :asset_manager, AssetManager.EventStore, serializer: Commanded.Serialization.JsonSerializer

# Configures the endpoint
config :asset_manager, AssetManagerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "OrAg1VfnLCmsGE1EDRiw8RIl3aqJ3M9i2nUCwS5tS9HC0kIjk8e2otCTfq7gPDMy",
  render_errors: [view: AssetManagerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: AssetManager.PubSub,
  live_view: [signing_salt: "W28ZODVq"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :stream_uuid, :trace_id, :span_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :opentelemetry,
  span_processor: :batch,
  traces_exporter: :none,
  resource: [
    service: [
      name: "asset-manager"
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
