defmodule DummyDefinitionTwo do
  def url(_, :original, _), do: "fallback"
  def url(_, :signed, _), do: "fallback?a=1&b=2"
  def store({file, _}), do: {:ok, file}
  def delete(_), do: :ok
  defoverridable [delete: 1, url: 3]
  use Arc.Ecto.Definition
end
