defmodule ArcTest.Ecto.Model do
  use ExUnit.Case, async: false
  import Mock

  defmodule DummyDefinition do
    use Arc.Definition
    use Arc.Ecto.Definition
  end

  defmodule TestUser do
    use Ecto.Schema
    import Ecto.Changeset
    use Arc.Ecto.Model

    schema "users" do
      field :first_name, :string
      field :avatar, DummyDefinition.Type
    end

    def changeset(user, params \\ %{}) do
      user
      |> cast(params, ~w(first_name)a)
      |> cast_attachments(params, ~w(avatar))
      |> validate_required(:avatar)
    end
  end

  setup do
    defmodule DummyDefinition do
      use Arc.Definition
      use Arc.Ecto.Definition
    end

    :ok
  end

  test "supports %{} changeset" do
    cs = TestUser.changeset(%TestUser{})
    assert cs.valid? == false
    assert cs.changes == %{}
    assert cs.required == [:avatar]
  end

  test_with_mock "cascades storage success into a valid change", DummyDefinition, [store: fn({"/path/to/my/file.png", %TestUser{}}) -> {:ok, "file.png"} end] do
    cs = TestUser.changeset(%TestUser{}, %{"avatar" => "/path/to/my/file.png"})
    assert called DummyDefinition.store({"/path/to/my/file.png", %TestUser{}})
    assert cs.valid?
    %{file_name: "file.png", updated_at: updated_at} = cs.changes.avatar
    assert updated_at = %Ecto.DateTime{}
  end

  test_with_mock "cascades storage error into an error", DummyDefinition, [store: fn({"/path/to/my/file.png", %TestUser{}}) -> {:error, :invalid_file} end] do
    cs = TestUser.changeset(%TestUser{}, %{"avatar" => "/path/to/my/file.png"})
    assert called DummyDefinition.store({"/path/to/my/file.png", %TestUser{}})
    assert cs.valid? == false
    assert cs.errors == [avatar: "can't be blank", avatar: "is invalid"]
  end

  test_with_mock "converts changeset into model", DummyDefinition, [store: fn({"/path/to/my/file.png", %TestUser{}}) -> {:error, :invalid_file} end] do
    TestUser.changeset(%Ecto.Changeset{data: %TestUser{}}, %{"avatar" => "/path/to/my/file.png"})
    assert called DummyDefinition.store({"/path/to/my/file.png", %TestUser{}})
  end

  test_with_mock "applies changes to model", DummyDefinition, [store: fn({"/path/to/my/file.png", %TestUser{}}) -> {:error, :invalid_file} end] do
    TestUser.changeset(%Ecto.Changeset{data: %TestUser{}}, %{"avatar" => "/path/to/my/file.png", "first_name" => "test"})
    assert called DummyDefinition.store({"/path/to/my/file.png", %TestUser{first_name: "test"}})
  end

  test_with_mock "converts atom keys", DummyDefinition, [store: fn({"/path/to/my/file.png", %TestUser{}}) -> {:error, :invalid_file} end] do
    TestUser.changeset(%Ecto.Changeset{data: %TestUser{}}, %{avatar: "/path/to/my/file.png"})
    assert called DummyDefinition.store({"/path/to/my/file.png", %TestUser{}})
  end
end
