use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :edify, E.Repo,
  database: "edify_test",
  username: "postgres",
  password: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :edify, EWeb.Endpoint, server: false

# Print only warnings and errors during test
config :logger, level: :warn
