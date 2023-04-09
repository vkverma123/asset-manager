import Config

config :asset_manager, AssetManager.Repo,
  username: "postgres",
  password: "postgres",
  database: "asset_manager_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 1

config :asset_manager, AssetManager.EventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "postgres",
  password: "postgres",
  database: "asset_manager_eventstore_dev",
  hostname: "localhost",
  pool_size: 1

config :asset_manager, AssetManagerWeb.Endpoint,
  http: [port: 10000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :asset_manager, AssetManager.PromEx, disabled: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
