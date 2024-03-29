defmodule CartEngine.MixProject do
  use Mix.Project

  def project do
    [
      app: :cart_engine,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {CartEngine.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:redix, ">= 0.7.1"},
      {:uuid, "~> 1.1"},
    ]
  end
end
