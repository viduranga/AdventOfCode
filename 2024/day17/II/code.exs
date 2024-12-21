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

  def step(registers, pointer, program, size) do
    if pointer >= size do
      []
    else
      {op, arg} = Enum.at(program, pointer)
      {registers, pointer, out} = evaluate(op, arg, pointer, registers)
      next_out = step(registers, pointer, program, size)

      if out != nil do
        [out | next_out]
      else
        next_out
      end
    end
  end

  def find_bounds(program, pointer, min_a, max_a, instructions) do
    # I want to use 1000 but it breaks and returns a bit larger value. 
    # Somehow, the correct value slips between the steps 
    step = div(max_a - min_a, 10000) |> max(1)
    max_a = (rem(max_a, step) == 0 && max_a) || max_a + step

    expeceted_val_at_pointer = Enum.at(program, pointer)

    instructions_len = Enum.count(instructions)

    for(
      a <- min_a..max_a//step,
      do: {M.step(%{:a => a, :b => 0, :c => 0}, 0, instructions, instructions_len), a}
    )
    |> Enum.filter(fn {out, _} -> Enum.count(out) == Enum.count(program) end)
    |> Enum.map_reduce({0, nil}, fn {out, a}, {group, prev} ->
      val_at_pointer = Enum.at(out, pointer)

      case prev do
        x when x in [nil, val_at_pointer] -> {{out, a, group}, {group, val_at_pointer}}
        _ -> {{out, a, group + 1}, {group + 1, val_at_pointer}}
      end
    end)
    |> elem(0)
    |> Enum.filter(fn {out, _, _} ->
      val_at_pointer = Enum.at(out, pointer)

      val_at_pointer == expeceted_val_at_pointer
    end)
    |> Enum.group_by(fn {_, _, group} -> group end)
    |> Enum.map(fn {_, outs} ->
      as = Enum.map(outs, fn {_, a, _} -> a end)

      {Enum.min(as), Enum.max(as)}
    end)
  end

  def scan_a(program, pointer, instructions, min, max) do
    if pointer == -1 and min == max do
      instructions_len = Enum.count(instructions)
      out = step(%{:a => min, :b => 0, :c => 0}, 0, instructions, instructions_len)

      if program == out do
        min
      else
        :infinity
      end
    else
      min_max_groups = find_bounds(program, pointer, min, max, instructions)

      res =
        for(
          {min, max} <- min_max_groups,
          do: scan_a(program, pointer - 1, instructions, min, max)
        )

      case res do
        [] -> :infinity
        _ -> Enum.min(res)
      end
    end
  end
end

[_, program] =
  System.argv()
  |> File.read!()
  |> String.split("\n\n", trim: true)
  |> Enum.map(&String.trim/1)

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

min = 1
max = 1_000_000_000_000_000

IO.inspect(
  M.scan_a(
    program,
    Enum.count(program) - 1,
    instructions,
    min,
    max
  )
)
