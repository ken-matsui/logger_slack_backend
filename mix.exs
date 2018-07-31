defmodule LoggerSlackBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :logger_slack_backend,
      version: "0.1.0",
      elixir: "~> 1.6",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  defp description do
    "Simple logger backend that sends to Slack channel using webhook API"
  end

  defp package do
    [
      maintainers: ["Ken Matsui"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/matken11235/logger_slack_backend"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.2"},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19.0", only: :dev}
    ]
  end
end
