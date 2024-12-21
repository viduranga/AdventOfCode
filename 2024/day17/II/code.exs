defmodule M do
  import Bitwise

  def get_combo_arg(arg, registers) do
    case arg do
      4 -> registers[:a]
      5 -> registers[:b]
      6 -> registers[:c]
      _ -> arg
    end
  end

  def evaluate(op, arg, pointer, registers) do
    case op do
      :adv ->
        num = registers[:a]
        den = 2 ** get_combo_arg(arg, registers)
        res = div(num, den)

        {Map.put(registers, :a, res), pointer + 1, nil}

      :bxl ->
        res = bxor(registers[:b], arg)
        {Map.put(registers, :b, res), pointer + 1, nil}

      :bst ->
        res = rem(get_combo_arg(arg, registers), 8)

        {Map.put(registers, :b, res), pointer + 1, nil}

      :jnz ->
        if registers[:a] != 0 do
          {registers, div(arg, 2), nil}
        else
          {registers, pointer + 1, nil}
        end

      :bxc ->
        res = bxor(registers[:b], registers[:c])
        {Map.put(registers, :b, res), pointer + 1, nil}

      :out ->
        res = rem(get_combo_arg(arg, registers), 8)
        {registers, pointer + 1, res}

      :bdv ->
        num = registers[:a]
        den = 2 ** get_combo_arg(arg, registers)
        res = div(num, den)

        {Map.put(registers, :b, res), pointer + 1, nil}

      :cdv ->
        num = registers[:a]
        den = 2 ** get_combo_arg(arg, registers)
        res = div(num, den)

        {Map.put(registers, :c, res), pointer + 1, nil}
    end
  end

  def step(registers, pointer, program, size, cache) do
    if Map.has_key?(cache, {registers, pointer}) do
      {cache, Map.get(cache, {registers, pointer})}
    else
      if pointer == size do
        {Map.put(cache, {registers, pointer}, []), []}
      else
        {op, arg} = Enum.at(program, pointer)
        {new_registers, new_pointer, out} = evaluate(op, arg, pointer, registers)
        {cache, next_out} = step(new_registers, new_pointer, program, size, cache)

        this_out =
          if out != nil do
            [out | next_out]
          else
            next_out
          end

        cache = Map.put(cache, {registers, pointer}, this_out)
        {cache, this_out}
      end
    end
  end

  def try_a(a, instructions, size, cache, program) do
    {cache, out} = step(%{:a => a, :b => 0, :c => 0}, 0, instructions, size, cache)

    if out == program do
      a
    else
      try_a(a + 1, instructions, size, cache, program)
    end
  end
end

[registers, program] =
  System.argv()
  |> File.read!()
  |> String.split("\n\n", trim: true)
  |> Enum.map(&String.trim/1)

registers =
  Regex.named_captures(
    ~r/^Register A: (?<a>\d+)\nRegister B: (?<b>\d+)\nRegister C: (?<c>\d+)$/,
    registers
  )
  |> Enum.map(fn {key, val} -> {String.to_atom(key), String.to_integer(val)} end)
  |> Enum.into(%{})

program =
  String.split(program, " ", trim: true)
  |> Enum.at(1)
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_integer/1)

instructions =
  program
  |> Enum.chunk_every(2)
  |> Enum.map(fn [op, arg] ->
    op =
      case op do
        0 -> :adv
        1 -> :bxl
        2 -> :bst
        3 -> :jnz
        4 -> :bxc
        5 -> :out
        6 -> :bdv
        7 -> :cdv
      end

    {op, arg}
  end)

{_, out} =
  M.step(
    Map.put(registers, :a, 10_000_000_000_0000),
    0,
    instructions,
    Enum.count(instructions),
    %{}
  )

IO.inspect(out)
IO.inspect(M.try_a(100_000_000_000_000, instructions, Enum.count(instructions), %{}, program))
