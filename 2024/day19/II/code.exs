defmodule M do
  def cached_remove_pattern(towel, patterns, cache) do
    if Map.has_key?(cache, towel) do
      {Map.get(cache, towel), cache}
    else
      res = remove_patterns(towel, patterns)
      cache = Map.put(cache, towel, res)
      {res, cache}
    end
  end

  def remove_patterns(towel, patterns) do
    for pattern <- patterns do
      case Regex.named_captures(pattern, towel) do
        %{"rest" => rest} ->
          if rest == "" do
            [[pattern]]
          else
            remove_patterns(rest, patterns)
            |> Enum.map(fn
              [] ->
                []

              hits ->
                [pattern | hits]
            end)
          end

        nil ->
          [[]]
      end
    end
    |> Stream.flat_map(& &1)
    |> Enum.to_list()
    |> Enum.filter(&(&1 != []))
    |> Enum.uniq()
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

options =
  Enum.map(towels, fn towel ->
    M.remove_patterns(towel, Map.keys(patterns))
    |> Enum.map(fn path ->
      Enum.map(path, fn pattern ->
        patterns[pattern]
      end)
    end)
    |> Enum.count()
  end)

IO.inspect(options |> Enum.sum())
