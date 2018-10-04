defmodule ArcTest.Ecto.Definition do
  use ExUnit.Case

  test "defines Definition.Type module" do
    assert DummyDefinitionTwo.Type.type == Arc.Ecto.Type.type
  end

  test "falls back to pre-defined url" do
    assert DummyDefinitionTwo.url("test.png", :original, []) == "fallback"
  end

  test "url appends timestamp to url with no query parameters" do
    updated_at = NaiveDateTime.from_erl!({{2015, 1, 1}, {1, 1, 1}})
    url = DummyDefinitionTwo.url({%{file_name: "test.png", updated_at: updated_at}, :scope}, :original, [])
    assert url == "fallback?v=63587293261"
  end

  test "url appends timestamp to url with query parameters" do
    updated_at = NaiveDateTime.from_erl!({{2015, 1, 1}, {1, 1, 1}})
    url = DummyDefinitionTwo.url({%{file_name: "test.png", updated_at: updated_at}, :scope}, :signed, [])
    assert url == "fallback?a=1&b=2&v=63587293261"
  end

  test "url is unchanged if no timestamp is present" do
    url = DummyDefinitionTwo.url({%{file_name: "test.png", updated_at: nil}, :scope}, :original, [])
    assert url == "fallback"
  end
end
