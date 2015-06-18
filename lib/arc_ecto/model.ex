defmodule Arc.Ecto.Model do
  defmacro __using__(_) do
    quote do
      import Arc.Ecto.Model
    end
  end

  defmacro cast_attachments(changeset_or_model, params, required, optional) do
    quote bind_quoted: [changeset_or_model: changeset_or_model,
                        params: params,
                        required: required,
                        optional: optional] do


      # If given a changeset, extract the underlying model
      scope = case changeset_or_model do
        %Ecto.Changeset{model: model} -> model
        %{__meta__: schema} -> changeset_or_model
      end

      # Transform value as a tuple of {value, scope}
      arc_params = Dict.take(params, required ++ optional)
        |> Enum.map(fn({field, file}) -> {field, {file, scope}} end)
        |> Enum.into(%{})

      cast(changeset_or_model, arc_params, required, optional)
    end
  end
end
