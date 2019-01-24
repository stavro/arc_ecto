defmodule ArcTest.Ecto.Changeset do
  use ExUnit.Case, async: false
  import Mock
  import ExUnit.CaptureLog

  defmodule TestUser do
    use Ecto.Schema
    import Ecto.Changeset
    import Arc.Ecto.Changeset

    schema "users" do
      field :first_name, :string
      field :avatar, DummyDefinition.Type
    end

    def changeset(user, params \\ :invalid) do
      user
      |> cast(params, ~w(first_name)a)
      |> cast_attachments(params, ~w(avatar)a)
      |> validate_required(:avatar)
    end

    def path_changeset(user, params \\ :invalid) do
      user
      |> cast(params, ~w(first_name)a)
      |> cast_attachments(params, ~w(avatar)a, allow_paths: true)
      |> validate_required(:avatar)
    end

    def changeset2(user, params \\ :invalid) do
      user
      |> cast(params, ~w(first_name)a)
      |> cast_attachments(params, ~w(avatar)a)
    end
  end

  def build_upload(path) do
    %{__struct__: Plug.Upload, path: path, filename: Path.basename(path)}
  end

  test "supports :invalid changeset" do
    cs = TestUser.changeset(%TestUser{})
    assert cs.valid?   == false
    assert cs.changes  == %{}
    assert cs.errors   == [avatar: {"can't be blank", [validation: :required]}]
  end

  test_with_mock "cascades storage success into a valid change", DummyDefinition, [store: fn({%{__struct__: Plug.Upload, path: "/path/to/my/file.png", filename: "file.png"}, %TestUser{}}) -> {:ok, "file.png"} end] do
    upload = build_upload("/path/to/my/file.png")
    cs = TestUser.changeset(%TestUser{}, %{"avatar" => upload})
    assert cs.valid?
    %{file_name: "file.png", updated_at: _} = cs.changes.avatar
  end

  test_with_mock "cascades storage error into an error", DummyDefinition, [store: fn({%{__struct__: Plug.Upload, path: "/path/to/my/file.png", filename: "file.png"}, %TestUser{}}) -> {:error, :invalid_file} end] do
    upload = build_upload("/path/to/my/file.png")
    capture_log(fn ->
      cs = TestUser.changeset(%TestUser{}, %{"avatar" => upload})
      assert called DummyDefinition.store({upload, %TestUser{}})
      assert cs.valid? == false
      assert cs.errors == [avatar: {"is invalid", [type: DummyDefinition.Type, validation: :cast]}]
    end)
  end

  test_with_mock "converts changeset into schema", DummyDefinition, [store: fn({%{__struct__: Plug.Upload, path: "/path/to/my/file.png", filename: "file.png"}, %TestUser{}}) -> {:error, :invalid_file} end] do
    upload = build_upload("/path/to/my/file.png")
    capture_log(fn ->
      TestUser.changeset(%TestUser{}, %{"avatar" => upload})
      assert called DummyDefinition.store({upload, %TestUser{}})
    end)
  end

  test_with_mock "applies changes to schema", DummyDefinition, [store: fn({%{__struct__: Plug.Upload, path: "/path/to/my/file.png", filename: "file.png"}, %TestUser{}}) -> {:error, :invalid_file} end] do
    upload = build_upload("/path/to/my/file.png")
    capture_log(fn ->
      TestUser.changeset(%TestUser{}, %{"avatar" => upload, "first_name" => "test"})
      assert called DummyDefinition.store({upload, %TestUser{first_name: "test"}})
    end)
  end

  test_with_mock "converts atom keys", DummyDefinition, [store: fn({%{__struct__: Plug.Upload, path: "/path/to/my/file.png", filename: "file.png"}, %TestUser{}}) -> {:error, :invalid_file} end] do
    upload = build_upload("/path/to/my/file.png")
    capture_log(fn ->
      TestUser.changeset(%TestUser{}, %{avatar: upload})
      assert called DummyDefinition.store({upload, %TestUser{}})
    end)
  end

  test_with_mock "casting nil attachments", DummyDefinition, [store: fn({%{__struct__: Plug.Upload, path: "/path/to/my/file.png", filename: "file.png"}, %TestUser{}}) -> {:ok, "file.png"} end] do
    changeset = TestUser.changeset(%TestUser{}, %{"avatar" => build_upload("/path/to/my/file.png")})
    changeset = TestUser.changeset2(changeset, %{"avatar" => nil})
    assert nil == Ecto.Changeset.get_field(changeset, :avatar)
  end

  test_with_mock "allow_paths => true", DummyDefinition, [store: fn({"/path/to/my/file.png", %TestUser{}}) -> {:ok, "file.png"} end] do
    _changeset = TestUser.path_changeset(%TestUser{}, %{"avatar" => "/path/to/my/file.png"})
    assert called DummyDefinition.store({"/path/to/my/file.png", %TestUser{}})
  end
end
