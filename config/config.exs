# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :inject_detect,
  ecto_repos: [InjectDetect.Repo]

# Configures the endpoint
config :inject_detect, InjectDetect.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "oCddWF0eW1lZnO5dNZAN8ggjejFNrzbqq7Ma4PowbEkSmFKSwMxlc9qmfDTdpJhL",
  render_errors: [view: InjectDetect.ErrorView, accepts: ~w(html json)],
  pubsub: [name: InjectDetect.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :inject_detect, InjectDetect.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "email-smtp.us-east-1.amazonaws.com",
  port: 587,
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  tls: :if_available, # can be `:always` or `:never`
  ssl: false, # can be `true`
  retries: 1

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
