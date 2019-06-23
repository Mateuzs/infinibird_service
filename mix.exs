defmodule InfinibirdService.MixProject do
  use Mix.Project

  def project do
    [
      app: :infinibird_service,
      version: "0.3.5",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {InfinibirdService.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.0"},
      {:plug, "~> 1.6"},
      {:plug_cowboy, "~> 2.0.2"},
      {:basic_auth, "~> 2.2.3"}
    ]
  end
end
