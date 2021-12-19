defmodule Arc.Ecto.Mixfile do
  use Mix.Project

  @source_url "https://github.com/stavro/arc_ecto"
  @version "0.11.3"

  def project do
    [
      app: :arc_ecto,
      version: @version,
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :arc]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      description: "An integration with Arc and Ecto.",
      maintainers: ["Sean Stavropoulos"],
      licenses: ["Apache-2.0"],
      files: ~w(mix.exs README.md lib),
      links: %{
        "Changelog" => "https://hexdocs.pm/arc_ecto/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp deps do
    [
      {:arc, "~> 0.11.0"},
      {:ecto, ">= 2.1.0"},
      {:mock, "~> 0.3.3", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
