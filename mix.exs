defmodule Arc.Ecto.Mixfile do
  use Mix.Project

  @version "0.4.0"

  def project do
    [app: :arc_ecto,
     version: @version,
     elixir: "~> 1.0",
     deps: deps,

    # Hex
     description: description,
     package: package]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

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

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:arc, "~> 0.2"},
      {:ecto, "~> 2.0.0-rc.3"},
      {:mock, "~> 0.1.1", only: :test}
    ]
  end
end
