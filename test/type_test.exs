defmodule ArcTest.Ecto.Type do
  use ExUnit.Case

  defmodule DummyDefinition do
    use Arc.Definition
    use Arc.Ecto.Definition
  end

  test "handles not having a timestamp in value for load" do
    {:ok, file} = Arc.Ecto.Type.load(DummyDefinition, "testing.jpg")

    assert file.file_name == "testing.jpg"
    assert file.updated_at == Ecto.DateTime.from_erl({{0, 1, 1}, {0, 0, 0}})
  end

  test "handles having a a timestamp in value for load" do
    {:ok, file} = Arc.Ecto.Type.load(DummyDefinition, "testing.jpg?63587293161")

    assert file.file_name == "testing.jpg"
    assert file.updated_at == Ecto.DateTime.from_erl({{2015, 1, 1}, {0, 59, 21}})
  end
end
