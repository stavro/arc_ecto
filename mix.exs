defmodule Arc.Ecto.Mixfile do
  use Mix.Project

  @version "0.11.1"

  def project do
    [app: :arc_ecto,
     version: @version,
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     deps: deps(),

    # Hex
     description: description(),
     package: package()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :arc]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp description do
    """
    An integration with Arc and Ecto.
    """
  end

  defp package do
    [maintainers: ["Sean Stavropoulos"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/stavro/arc_ecto"},
     files: ~w(mix.exs README.md lib)]
  end

  defp deps do
    [
      {:arc,  "~> 0.11.0"},
      {:ecto, "~> 2.1 or ~> 3.0"},
      {:mock, "~> 0.3.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
