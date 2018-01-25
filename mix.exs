defmodule BigchaindbEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bigchaindb_ex,
      version: "0.1.0",
      elixir: "~> 1.5",
      erlc_paths: ["lib"],
      start_permanent: Mix.env == :prod,
      compilers: [:crypto_nifs] ++ Mix.compilers,
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
      {:enacl, github: "jlouis/enacl"},
      {:eqc_ex, "~> 1.4", only: [:test]}
    ]
  end
end

defmodule Mix.Tasks.Compile.CryptoNifs do
  def run(_) do
    if match? {:win32, _}, :os.type do
      {result, _error_code} = System.cmd("nmake", ["/F", "Makefile.win", "priv\\crypto_nifs.dll"], stderr_to_stdout: true)
      Mix.shell.info result
    else
      {result, _error_code} = System.cmd("make", ["priv/crypto_nifs.so"], stderr_to_stdout: true)
      Mix.shell.info result
    end
    :ok
  end
end
