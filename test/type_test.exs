defmodule ArcTest.Ecto.Type do
  use ExUnit.Case, async: false

  defmodule DummyDefinition do
    use Arc.Definition
    use Arc.Ecto.Definition
  end

  test "dumps filenames with timestamp" do
    timestamp = Ecto.DateTime.cast!({{1970, 1, 1}, {0, 0, 0}})
    {:ok, value} =
      DummyDefinition.Type.dump(%{file_name: "file.png", updated_at: timestamp})
    assert value == "file.png?62167219200"
  end

  test "loads filenames with timestamp" do
    timestamp = Ecto.DateTime.cast!({{1970, 1, 1}, {0, 0, 0}})
    {:ok, value} = DummyDefinition.Type.load("file.png?62167219200")
    assert value == %{file_name: "file.png", updated_at: timestamp}
  end
end
