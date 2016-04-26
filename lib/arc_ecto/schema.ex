defmodule Arc.Ecto.Schema do
  defmacro __using__(_) do
    quote do
      import Arc.Ecto.Schema
    end
  end

  defmacro cast_attachments(changeset_or_data, params, allowed) do
    quote bind_quoted: [changeset_or_data: changeset_or_data,
                        params: params,
                        allowed: allowed] do

      # If given a changeset, apply the changes to obtain the underlying data
      scope = case changeset_or_data do
        %Ecto.Changeset{} -> Ecto.Changeset.apply_changes(changeset_or_data)
        %{__meta__: _} -> changeset_or_data
      end

      # Cast supports both atom and string keys, ensure we're matching on both.
      allowed = Enum.map(allowed, fn key ->
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
          |> Dict.take(allowed)
          |> Enum.map(fn({field, file}) -> {field, {file, scope}} end)
          |> Enum.into(%{})
      end

      cast(changeset_or_data, arc_params, allowed)
    end
  end

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
