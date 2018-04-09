# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :latency_check, LatencyCheckWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "q99AkzMEBOqwa3kAkId9GDSY64H2H2kc1Rtax1jopyuMl+tpEaicFdKGY47hsOy8",
  render_errors: [view: LatencyCheckWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LatencyCheck.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :template_engines,
    slim: PhoenixSlime.Engine,
    slime: PhoenixSlime.Engine

import_config "#{Mix.env}.exs"
