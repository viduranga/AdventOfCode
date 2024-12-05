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
  |> Enum.map(fn x ->
    [a, b] = String.split(x, "|", trim: true)

    {~r/(^|,)#{a},(\d+,)*#{b}($|,)/, a, b}
  end)

correct_prints =
  prints
  |> Enum.map(fn x -> String.split(x, ",") end)
  |> Enum.filter(fn array ->
    Enum.all?(rules, fn {rule, a, b} ->
      string = Enum.join(array, ",")

      if Enum.member?(array, a) && Enum.member?(array, b) do
        Regex.match?(rule, string)
      else
        true
      end
    end)
  end)
  |> Enum.map(fn x ->
    middle = Integer.floor_div(Enum.count(x), 2)
    String.to_integer(Enum.at(x, middle))
  end)

IO.inspect(correct_prints |> Enum.sum())
