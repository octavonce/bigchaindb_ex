defmodule BigchaindbEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bigchaindb_ex,
      version: "0.1.0",
      elixir: "~> 1.5",
      erlc_paths: ["lib"],
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpotion, "~> 3.0.2"},
      {:poison, "~> 3.1"},
      {:hexate,  ">= 0.6.0"},
      {:enacl, github: "jlouis/enacl", tag: "master"},
      {:eqc_ex, "~> 1.4", only: [:test]}
    ]
  end
end
