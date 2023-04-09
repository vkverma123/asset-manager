import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :asset_manager, AssetManager.Repo,
  username: "postgres",
  password: "postgres",
  database: "asset_manager_test",
  hostname: "localhost",
  pool_size: 2

config :asset_manager, AssetManager.EventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "postgres",
  password: "postgres",
  database: "asset_manager_eventstore_test",
  hostname: "localhost",
  pool_size: 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :asset_manager, AssetManagerWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
