defmodule Arc.Ecto.Type do
  def type, do: :string

  def cast(definition, args) do
    case definition.store(args) do
      {:ok, file} -> {:ok, %{file_name: file, updated_at: Ecto.DateTime.utc}}
      _ -> :error
    end
  end

  def cast(definition, _other), do: :error

  def load(definition, value) do
    [_, file_name, gsec] = Regex.run(~r{^(.*)\?(\d+)$}, value)
    updated_at = Ecto.DateTime.from_erl(:calendar.gregorian_seconds_to_datetime(String.to_integer(gsec)))
    {:ok, %{file_name: file_name, updated_at: updated_at}}
  end

  def dump(definition, %{file_name: file_name, updated_at: updated_at}) do
    gsec = :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(updated_at))
    {:ok, "#{file_name}?#{gsec}"}
  end
end
