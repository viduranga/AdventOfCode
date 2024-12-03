# THIS IS A DISGRACE
# Bruteforce solution
# I just wanted to finish this and move on to the next one

defmodule M do
  def same_direction(array) do
    Enum.all?(array, fn [x, _] -> x in [:increasing, :skipped] end) ||
      Enum.all?(array, fn [x, _] -> x in [:decreasing, :skipped] end)
  end

  def all_safe(array) do
    same_direction(array) &&
      Enum.all?(array, fn [_, [a, b, _]] -> a == nil || abs(a - b) in 1..3 end)
  end

  def one_wrong_direction(array) do
    array_len = Enum.count(array)

    array
    |> Enum.reject(fn [x, _] -> x == :skipped end)
    |> Enum.frequencies_by(fn [x, _] -> x end)
    |> Enum.any?(fn {_, count} -> count == array_len - 2 end)

    # Subtract 2 because we have also removed the head  
    true
  end

  def drop_mutations(array_with_index, drop) do
    for i <- drop do
      array_with_index
      |> Enum.reject(fn {_, index} -> index == i end)
    end
  end

  def stamp_states(arrays) do
    arrays
    |> Enum.map(fn array ->
      Enum.chunk_every([nil] ++ array ++ [nil], 3, 1, :discard)
    end)
    |> Enum.map(fn array ->
      array
      |> Enum.map(fn [a, b, c] ->
        direction =
          cond do
            a == nil -> :skipped
            a > b -> :decreasing
            a < b -> :increasing
            a == b -> :plateau
          end

        [direction, [a, b, c]]
      end)
    end)
  end
end

# Read the file and parse the content
content =
  System.argv()
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn x ->
    String.split(x, " ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end)

state = M.stamp_states(content)

same_path_safe =
  state
  |> Enum.filter(&M.all_safe(&1))

potentially_fixable =
  state
  |> Enum.reject(&M.same_direction(&1))
  |> Enum.filter(&M.one_wrong_direction(&1))
  |> Enum.map(fn array ->
    array
    |> Enum.map(fn [_, [a, b, c]] -> [a, b, c] end)
    |> Enum.with_index()
  end)

fixable_indexes =
  potentially_fixable
  |> Enum.map(fn array ->
    array
    |> Enum.filter(fn {[a, b, c], _} ->
      cond do
        a == nil -> if abs(b - c) in 1..3, do: false, else: true
        c == nil -> if abs(a - b) in 1..3, do: false, else: true
        a < b && b < c -> false
        a > b && b > c -> false
        true -> true
      end
    end)
    |> Enum.map(fn {_, index} -> index end)
  end)

fix_mutations =
  Enum.zip(potentially_fixable, fixable_indexes)
  |> Enum.map(fn {array, drop} -> M.drop_mutations(array, drop) end)
  |> Enum.map(fn mutations ->
    Enum.map(mutations, fn mutation ->
      Enum.map(mutation, fn {[_, val, _], _} -> val end)
    end)
  end)

edge_case =
  state
  |> Enum.reject(&M.all_safe(&1))
  |> Enum.filter(&M.same_direction(&1))
  |> Enum.map(fn array ->
    array
    |> Enum.map(fn [_, [a, b, c]] -> [a, b, c] end)
    |> Enum.with_index()
  end)
  |> Enum.map(fn array -> M.drop_mutations(array, [0, Enum.count(array) - 1]) end)
  |> Enum.map(fn mutations ->
    Enum.map(mutations, fn mutation ->
      Enum.map(mutation, fn {[_, val, _], _} -> val end)
    end)
  end)

fixed_safe =
  (fix_mutations ++ edge_case)
  |> Enum.filter(fn mutations ->
    M.stamp_states(mutations)
    |> Enum.any?(&M.all_safe(&1))
  end)

result = Enum.count(same_path_safe) + Enum.count(fixed_safe)
IO.inspect(result)
