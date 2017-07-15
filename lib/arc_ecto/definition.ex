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

      def url({%{file_name: file_name, updated_at: updated_at}, scope}, version, options) do
        url = super({file_name, scope}, version, options)

        if options[:signed] do
          url
        else
          case updated_at do
            %NaiveDateTime{} ->
              stamp = :calendar.datetime_to_gregorian_seconds(NaiveDateTime.to_erl(updated_at))
              case URI.parse(url).query do
                nil -> url <> "?v=#{stamp}"
                _ -> url <> "&v=#{stamp}"
              end
            _ -> url
          end
        end
      end

      def url(f, v, options), do: super(f, v, options)
      
      def delete({%{file_name: file_name, updated_at: _updated_at}, scope}), do: super({file_name, scope})

      def delete(args), do: super(args)
    end
  end
end
