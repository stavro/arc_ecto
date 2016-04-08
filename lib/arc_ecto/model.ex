defmodule Arc.Ecto.Model do
  defmacro __using__(_) do
    quote do
      import Arc.Ecto.Model
    end
  end

  defmacro cast_attachments(changeset_or_model, params, allowed) do
    quote bind_quoted: [changeset_or_model: changeset_or_model,
                        params: params,
                        allowed: allowed] do

      # If given a changeset, apply the changes to obtain the underlying model
      scope = case changeset_or_model do
        %Ecto.Changeset{} -> Ecto.Changeset.apply_changes(changeset_or_model)
        %{__meta__: _} -> changeset_or_model
      end

      arc_params = case params do
        %{} ->
          params
          |> Arc.Ecto.Model.convert_params_to_binary
          |> Dict.take(allowed)
          |> Enum.map(fn({field, file}) -> {field, {file, scope}} end)
          |> Enum.into(%{})
      end

      cast(changeset_or_model, arc_params, allowed)
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
