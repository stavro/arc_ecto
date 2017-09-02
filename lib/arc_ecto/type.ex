defmodule Arc.Ecto.Type do
  def type, do: :string

  @filename_with_timestamp ~r{^(.*)\?(\d+)(&|$)}

  @saved_versions ~r/(files=)(.*)?&?/

  # Support embeds_one/embeds_many
  def cast(_definition, %{"file_name" => file, "updated_at" => updated_at}) do
    {:ok, %{file_name: file, updated_at: updated_at}}
  end

  def cast(_definition, %{"file_name" => file, "updated_at" => updated_at, "saved_versions" => saved_versions}) do
    {:ok, %{file_name: file, updated_at: updated_at, saved_versions: saved_versions}}
  end

  def cast(definition, args) do
    case definition.store(args) do
      {:ok, file, saved_versions} -> {:ok, %{file_name: file, updated_at: Ecto.DateTime.utc, saved_versions: saved_versions}}
      _ -> :error
    end
  end

  def load(_definition, value) do
    {file_name, gsec} = filename_from(value)
    updated_at = updated_time_from(gsec)
    saved_versions = saved_versions_from(value)
    case is_nil(saved_versions) do
      true ->     {:ok, %{file_name: file_name, updated_at: updated_at}}
      false ->     {:ok, %{file_name: file_name, updated_at: updated_at, saved_versions: saved_versions}}
    end
  end

  def dump(_definition, %{file_name: file_name, updated_at: nil}) do
    {:ok, file_name}
  end

  def dump(_definition, %{file_name: file_name, updated_at: updated_at}) do
    gsec = :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(updated_at))
    {:ok, "#{file_name}?#{gsec}"}
  end

  def dump(_definition, %{file_name: file_name, updated_at: updated_at, saved_versions: nil}) do
    gsec = :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(updated_at))
    {:ok, "#{file_name}?#{gsec}"}
  end

  def dump(_definition, %{file_name: file_name, updated_at: updated_at, saved_versions: versions}) do
    gsec = :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(updated_at))
    {:ok, "#{file_name}?#{gsec}&files=#{versions}"}
  end

  defp filename_from(value) do
    case Regex.match?(@filename_with_timestamp, value) do
      true ->
        [_, file_name, gsec, _] = Regex.run(@filename_with_timestamp, value)
        {file_name, gsec}
      _ -> {value, nil}
    end
  end

  defp saved_versions_from(value) do
    case Regex.match?(@saved_versions, value) do
      true ->
        [_, _, val] = Regex.run(@saved_versions, value)
        String.split(val, "::")
      _ -> nil
    end
  end

  defp updated_time_from(gsec) do
    case gsec do
      gsec when is_binary(gsec) ->
        gsec
        |> String.to_integer()
        |> :calendar.gregorian_seconds_to_datetime()
        |> Ecto.DateTime.from_erl()
      _ -> nil
    end
  end
end
