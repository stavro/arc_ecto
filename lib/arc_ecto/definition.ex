defmodule Arc.Ecto.Definition do
  defmacro __using__(_options) do
    definition = __CALLER__.module

    quote do
      defmodule Module.concat(unquote(definition), "Type") do
        @behaviour Ecto.Type
        def type, do: Arc.Ecto.Type.type
        def cast(value), do: Arc.Ecto.Type.cast(unquote(definition), value)
        def load(value), do: Arc.Ecto.Type.load(unquote(definition), value)
        def dump(value), do: Arc.Ecto.Type.dump(unquote(definition), value)
      end

      def url({%{file_name: file_name, updated_at: %Ecto.DateTime{}=updated_at}, scope}, version, options) do
        stamp = :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(updated_at))
        url = super({file_name, scope}, version, options)

        case URI.parse(url).query do
          nil -> url <> "?v=#{stamp}"
          _ -> url <> "&v=#{stamp}"
        end
      end

      def url(f, v, options), do: super(f, v, options)
    end
  end
end
