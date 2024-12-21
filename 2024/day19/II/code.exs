defmodule M do
  def remove_patterns(towel, patterns, cache) do
    if Map.has_key?(cache, towel) do
      {cache[towel], cache}
    else
      {hits, cache} =
        Enum.map_reduce(patterns, cache, fn pattern, cache ->
          case Regex.named_captures(pattern, towel) do
            %{"rest" => rest} ->
              if rest == "" do
                {1, cache}
              else
                remove_patterns(rest, patterns, cache)
              end

            nil ->
              {0, cache}
          end
        end)

      hits = Enum.sum(hits)

      cache = Map.put(cache, towel, hits)

      {hits, cache}
    end
  end
end

[patterns, towels] =
  System.argv()
  |> File.read!()
  |> String.split("\n\n", trim: true)

patterns =
  String.split(patterns, ", ", trim: true)
  |> Enum.map(fn pattern ->
    {Regex.compile!("^(#{pattern})(?<rest>.*)$"), pattern}
  end)
  |> Map.new()

towels = String.split(towels, "\n", trim: true)

{options, _} =
  Enum.map_reduce(towels, %{}, fn towel, cache ->
    M.remove_patterns(towel, Map.keys(patterns), cache)
  end)

IO.inspect(options |> Enum.sum())
