use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rumbl, RumblWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :rumbl, Rumbl.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "rumbl_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 60_000,
  timeout: 60_000,
  pool_timeout: 60_000

# Decrease number of hashing rounds to speed up tests
# below is wrong (as of version 4 of comeonin as they "moved the configuration
# to the separate dependency libraries)
# config :comeonin,
#   bcrypt_log_rounds: 4,
#   pbkdf2_rounds: 1_000
config :bcrypt_elixir, :log_rounds, 1
