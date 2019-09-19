defmodule InfinibirdService.MixProject do
  use Mix.Project

  def project do
    [
      app: :infinibird_service,
      version: "0.1.2",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    apps =
      case Mix.env() do
        :dev -> [:logger, :remix]
        _env -> [:logger]
      end

    [
      extra_applications: apps,
      mod: {InfinibirdService.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 4.0"},
      {:plug, "~> 1.6"},
      {:plug_cowboy, "~> 2.0.2"},
      {:basic_auth, "~> 2.2.3"},
      {:remix, "~> 0.0.1", only: :dev},
      {:jason, "~> 1.0"},
      {:distance, "~> 0.2.2"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:argon2_elixir, "~> 2.0"}
    ]
  end
end
