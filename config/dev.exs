use Mix.Config

config :logger_slack_backend,
  backends: [
    {Poacpm.LoggerSlackBackend, :info}
  ]

config :logger, :info,
  level: :info,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
