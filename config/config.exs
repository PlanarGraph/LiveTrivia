# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :live_trivia, LiveTriviaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gqPP7O1r/e4Z2aHtav62NwTcDPBVnRA365hGyzJL/R5hZOpOiQsg3lNuEIGimYih",
  render_errors: [view: LiveTriviaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LiveTrivia.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "BMCRudYPwj9UD4jIpJvk+vhJmveugD/x"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
