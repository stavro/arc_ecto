defmodule ArcTest.Ecto.Definition do
  use ExUnit.Case

  defmodule DummyDefinition do
    def url(_, :original, _), do: "fallback"
    def url(_, :signed, _), do: "fallback?a=1&b=2"
    def store({file, _}), do: {:ok, file}
    def delete(_), do: :ok
    defoverridable [delete: 1, url: 3]
    use Arc.Ecto.Definition
  end

  test "defines Definition.Type module" do
    assert {:file, :in_memory} == :code.is_loaded(DummyDefinition.Type)
    assert DummyDefinition.Type.type == Arc.Ecto.Type.type
  end

  test "falls back to pre-defined url" do
    assert DummyDefinition.url("test.png", :original, []) == "fallback"
  end

  test "url appends timestamp to url with no query parameters" do
    updated_at = NaiveDateTime.from_erl!({{2015, 1, 1}, {1, 1, 1}})
    url = DummyDefinition.url({%{file_name: "test.png", updated_at: updated_at}, :scope}, :original, [])
    assert url == "fallback?v=63587293261"
  end

  test "url appends timestamp to url with query parameters" do
    updated_at = NaiveDateTime.from_erl!({{2015, 1, 1}, {1, 1, 1}})
    url = DummyDefinition.url({%{file_name: "test.png", updated_at: updated_at}, :scope}, :signed, [])
    assert url == "fallback?a=1&b=2&v=63587293261"
  end

  test "url is unchanged if no timestamp is present" do
    url = DummyDefinition.url({%{file_name: "test.png", updated_at: nil}, :scope}, :original, [])
    assert url == "fallback"
  end
end
