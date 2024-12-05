defmodule M do
  def is_correct(print_map, rules) do
    Enum.all?(rules, fn [a, b] ->
      !Map.has_key?(print_map, a) || !Map.has_key?(print_map, b) || print_map[a] < print_map[b]
    end)
  end

  def fix_print(print_map, rules, rule_id, rule_count) do
    if rule_id === rule_count - 1 && M.is_correct(print_map, rules) do
      print_map
    else
      [a, b] = Enum.at(rules, rule_id)

      next_print_map =
        if Map.has_key?(print_map, a) && Map.has_key?(print_map, b) && print_map[a] > print_map[b] do
          Map.merge(print_map, %{a => print_map[b], b => print_map[a]})
        else
          print_map
        end

      fix_print(next_print_map, rules, rem(rule_id + 1, rule_count), rule_count)
    end
  end
end

#####################################
# Read the file and parse the content

content =
  System.argv()
  |> File.read!()
  |> String.split("\n\n", trim: true)

[rules, prints] = content

prints =
  prints
  |> String.split("\n", trim: true)

rules =
  rules
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "|", trim: true))

#####################################

incorrect_prints =
  prints
  |> Enum.map(fn print ->
    print
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.into(%{})
  end)
  |> Enum.reject(fn print_map ->
    M.is_correct(print_map, rules)
  end)

result =
  incorrect_prints
  |> Enum.map(fn print ->
    print
    |> M.fix_print(rules, 0, Enum.count(rules))
    |> Enum.sort_by(fn {_, i} -> i end)
  end)
  |> Enum.map(fn fixed ->
    middle = Integer.floor_div(Enum.count(fixed), 2)
    {x, _} = Enum.at(fixed, middle)
    String.to_integer(x)
  end)

IO.inspect(result |> Enum.sum())

IO.inspect(M.hello(1, 2))
