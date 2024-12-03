defmodule M do
  def map_instruction(instruction) do
    case instruction do
      "do()" ->
        true

      "don't()" ->
        false

      _ ->
        Regex.named_captures(~r/mul\((?<a>\d+),(?<b>\d+)\)/, instruction)
    end
  end
end

content =
  System.argv()
  |> File.read!()

content = "do()" <> content

result =
  Regex.scan(~r/mul\(\d+,\d+\)|do\(\)|don't\(\)/, content)
  |> Enum.map(fn [instruction] -> M.map_instruction(instruction) end)
  |> Enum.map(fn
    %{"a" => a, "b" => b} -> String.to_integer(a) * String.to_integer(b)
    x -> x
  end)

#####
# skill issues
# Don't know how to use Enum.reduce/3 to remove stuff between false and true
result =
  result
  |> Enum.join(".")

result =
  Regex.replace(~r/false\.(\d|\.)+/, result, "")
  |> String.split(".", trim: true)
  |> Enum.reject(&(&1 == "true"))
  |> Enum.map(&String.to_integer/1)

#####

result = Enum.sum(result)

IO.inspect(result)
