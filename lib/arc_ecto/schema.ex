defmodule Arc.Ecto.Schema do

  def cast_attachments(changeset_or_data, params, allowed) do
    arc_allowed = stringify_atoms(allowed)
    arc_params =  changeset_or_data
                  |> normalize_scope()
                  |> normalize_params(params, arc_allowed)
    Ecto.Changeset.cast(changeset_or_data, arc_params, arc_allowed)
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

  # If given a changeset, apply the changes to obtain the underlying data
  # It would be nice to know under what context this will not be a changeset.
  defp normalize_scope changeset_or_data do
    case changeset_or_data do
      %Ecto.Changeset{} -> Ecto.Changeset.apply_changes(changeset_or_data)
      %{__meta__: _} -> changeset_or_data #TODO: wont this cause normalize_params to fail?
    end
  end

  # Cast supports both atom and string keys, ensure we're matching on both.
  defp stringify_atoms list do
    Enum.map(list, fn key ->
      if is_atom(key) do
        Atom.to_string(key)
      else
        key
      end
    end)
  end

  defp normalize_params scope, params, allowed do
    case params do
      :invalid ->
        :invalid
      %{} ->
        params
        |> Arc.Ecto.Schema.convert_params_to_binary
        |> Dict.take(allowed)
        |> Enum.map(fn({field, file}) -> {field, {file, scope}} end)
        |> Enum.into(%{})
    end
  end
end
