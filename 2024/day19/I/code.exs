defmodule M do
  def remove_patterns(towel, patterns, pattern_id) do
    if pattern_id == Enum.count(patterns) - 1 do
      towel
    else
      pattern = Enum.at(patterns, pattern_id)

      case Regex.named_captures(pattern, towel) do
        %{"rest" => rest} ->
          if rest == "" do
            ""
          else
            removed = remove_patterns(rest, patterns, 0)

            if removed == "" do
              ""
            else
              remove_patterns(towel, patterns, pattern_id + 1)
            end
          end

        nil ->
          remove_patterns(towel, patterns, pattern_id + 1)
      end
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
    Regex.compile!("^(#{pattern})+(?<rest>.*)$")
  end)

towels = String.split(towels, "\n", trim: true)

cleared =
  towels
  |> Enum.map(fn towel ->
    M.remove_patterns(towel, patterns, 0)
  end)
  |> Enum.filter(&(&1 == ""))

IO.inspect(Enum.count(cleared))
