defmodule Arc.Ecto.Schema do
  defmacro __using__(_) do
    quote do
      import Arc.Ecto.Schema
    end
  end

  defmacro cast_attachments(changeset_or_data, params, allowed, options \\ []) do
    quote bind_quoted: [changeset_or_data: changeset_or_data,
                        params: params,
                        allowed: allowed,
                        options: options] do

      # If given a changeset, apply the changes to obtain the underlying data
      scope = do_apply_changes(changeset_or_data)

      # Cast supports both atom and string keys, ensure we're matching on both.
      allowed_param_keys = Enum.map(allowed, fn key ->
        case key do
          key when is_binary(key) -> key
          key when is_atom(key) -> Atom.to_string(key)
        end
      end)

      arc_params = case params do
        :invalid ->
          :invalid
        %{} ->
          params
          |> Arc.Ecto.Schema.convert_params_to_binary
          |> Map.take(allowed_param_keys)
          |> Enum.reduce([], fn
            # Don't wrap nil casts in the scope object
            {field, nil}, fields -> [{field, nil} | fields]

            # Allow casting Plug.Uploads
            {field, upload = %{__struct__: Plug.Upload}}, fields -> [{field, {upload, scope}} | fields]

            # Allow casting binary data structs
            {field, upload = %{filename: filename, binary: binary}}, fields
              when is_binary(filename) and is_binary(binary) ->
              [{field, {upload, scope}} | fields]

            # If casting a binary (path), ensure we've explicitly allowed paths
            {field, path}, fields when is_binary(path) ->
              cond do
                Keyword.get(options, :allow_urls, false) and Regex.match?( ~r/^https?:\/\// , path) -> [{field, {path, scope}} | fields]
                Keyword.get(options, :allow_paths, false) -> [{field, {path, scope}} | fields]
                true -> fields
              end
          end)
          |> Enum.into(%{})
      end

      Ecto.Changeset.cast(changeset_or_data, arc_params, allowed)
    end
  end

  def do_apply_changes(%Ecto.Changeset{} = changeset), do: Ecto.Changeset.apply_changes(changeset)
  def do_apply_changes(%{__meta__: _} = data), do: data

  def convert_params_to_binary(params) do
    Enum.reduce(params, nil, fn
      {key, _value}, nil when is_binary(key) ->
        nil

      {key, _value}, _ when is_binary(key) ->
        raise ArgumentError, "expected params to be a map with atoms or string keys, " <>
                             "got a map with mixed keys: #{inspect params}"

      {key, value}, acc when is_atom(key) ->
        Map.put(acc || %{}, Atom.to_string(key), value)

    end) || params
  end
end
