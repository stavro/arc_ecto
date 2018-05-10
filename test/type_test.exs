defmodule ArcTest.Ecto.Type do
  use ExUnit.Case, async: false

  defmodule DummyDefinition do
    use Arc.Definition
    use Arc.Ecto.Definition
  end

  test "dumps filenames with timestamp" do
    timestamp = NaiveDateTime.from_erl!({{1970, 1, 1}, {0, 0, 0}})
    {:ok, value} =
      DummyDefinition.Type.dump(%{file_name: "file.png", updated_at: timestamp})
    assert value == "file.png?62167219200"
  end

  test "loads filenames with timestamp" do
    timestamp = NaiveDateTime.from_erl!({{1970, 1, 1}, {0, 0, 0}})
    {:ok, value} = DummyDefinition.Type.load("file.png?62167219200")
    assert value == %{file_name: "file.png", updated_at: timestamp}
  end

  test "loads pathological filenames" do
    timestamp = NaiveDateTime.from_erl!({{1970, 1, 1}, {0, 0, 0}})
    {:ok, value} = DummyDefinition.Type.load("image.php?62167219200")
    assert value == %{file_name: "image.php", updated_at: timestamp}
  end

  test "loads pathological filenames without timestamps" do
    {:ok, value} = DummyDefinition.Type.load("image^!?*!=@$.php")
    assert value == %{file_name: "image^!?*!=@$.php", updated_at: nil}
  end

  test "dumps with updated_at" do
    timestamp = NaiveDateTime.from_erl!({{1970, 1, 1}, {0, 0, 0}})
    value = %{file_name: "file.png", updated_at: timestamp}
    {:ok, dumped_type} = DummyDefinition.Type.dump(value)
    assert dumped_type == "file.png?62167219200"
  end

  test "dumps without updated_at" do
    value = %{file_name: "file.png", updated_at: nil}
    {:ok, dumped_type} = DummyDefinition.Type.dump(value)
    assert dumped_type == "file.png"
  end
end
