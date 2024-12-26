defmodule M do
  def is_input(wire) do
    String.starts_with?(wire, "x") || String.starts_with?(wire, "y")
  end

  def is_first_input(wire) do
    String.ends_with?(wire, "00")
  end

  def is_output(wire) do
    String.starts_with?(wire, "z")
  end

  def is_first_output(wire) do
    wire == "z00"
  end

  def is_last_output(wire) do
    wire == "z45"
  end

  def z_output_from_xor(conns) do
    conns
    |> Enum.filter(fn {out, _} -> is_output(out) end)
    |> Enum.reject(fn {out, {_, gate, _}} ->
      gate == "XOR" || (gate == "OR" && is_last_output(out))
    end)
  end

  def internal_gates(conns) do
    conns
    |> Enum.filter(fn {output, {input1, _, input2}} ->
      !is_input(input1) && !is_input(input2) && !is_output(output)
    end)
    |> Enum.reject(fn {_, {_, gate, _}} ->
      gate in ["AND", "OR"]
    end)
  end

  # def or_output_to_xor_and_and(conns) do
  #   conns
  #   |> Enum.filter(fn {_, {_, gate, _}} -> gate == "OR" end)
  #   |> Enum.reject(fn {output, _} ->
  #     gates =
  #       Enum.filter(conns, fn {_, {input1, _, input2}} ->
  #         input1 == output || input2 == output
  #       end)
  #       |> Enum.map(fn {_, {_, gate, _}} -> gate end)
  #       |> Enum.sort()
  #
  #     if is_last_output(output) do
  #       gates == []
  #     else
  #       gates == ["AND", "XOR"]
  #     end
  #   end)
  # end
  #
  def and_goes_to_or(conns) do
    conns
    |> Enum.filter(fn {_, {_, gate, _}} -> gate == "AND" end)
    |> Enum.reject(fn {output, {input1, _, input2}} ->
      gates =
        Enum.filter(conns, fn {_, {input1, _, input2}} ->
          input1 == output || input2 == output
        end)
        |> Enum.map(fn {_, {_, gate, _}} -> gate end)
        |> Enum.sort()

      if is_first_input(input1) && is_first_input(input2) do
        gates == ["AND", "XOR"]
      else
        gates == ["OR"]
      end
    end)
  end

  #
  # def xor_output_to_xor_and_and(conns) do
  #   conns
  #   |> Enum.filter(fn {output, {_, gate, _}} -> gate == "XOR" and !is_output(output) end)
  #   |> Enum.reject(fn {output, _} ->
  #     ["AND", "XOR"] ==
  #       Enum.filter(conns, fn {_, {input1, _, input2}} ->
  #         input1 == output || input2 == output
  #       end)
  #       |> Enum.map(fn {_, {_, gate, _}} -> gate end)
  #       |> Enum.sort()
  #   end)
  # end
  #
  # def x_y_output_to_xor_and_and(conns) do
  #   conns
  #   |> Enum.filter(fn {_, {input1, _, input2}} -> is_input(input1) or is_input(input2) end)
  #   |> Enum.reject(fn {_, {input1, gate, input2}} ->
  #     {i1_id, i1_num} = String.split_at(input1, 1)
  #     {i2_id, i2_num} = String.split_at(input2, 1)
  #
  #     i1_num == i2_num and Enum.sort([i1_id, i2_id]) == ["x", "y"] and gate in ["AND", "XOR"]
  #   end)
  # end
  #
  def xor_chains(conns) do
    conns
    |> Enum.filter(fn {_, {input1, gate, input2}} ->
      gate == "XOR" and is_input(input1) and is_input(input2)
    end)
    |> Enum.reject(fn {output, _} ->
      if(is_first_output(output)) do
        true
      else
        next_outs =
          Enum.filter(conns, fn {_, {input1, gate, input2}} ->
            (input1 == output || input2 == output) and gate == "XOR"
          end)

        Enum.count(next_outs) == 1
      end
    end)
  end
end

[_, conns] =
  System.argv()
  |> File.read!()
  |> String.split("\n\n", trim: true)

conns =
  conns
  |> String.split("\n", trim: true)
  |> Enum.map(fn conn ->
    [inputs, output] = String.split(conn, " -> ", trim: true)
    [input1, gate, input2] = String.split(inputs, " ", trim: true)

    {output, {input1, gate, input2}}
  end)
  |> Map.new()

# (M.xor_output_to_xor_and_and(conns) ++
#    M.or_output_to_xor_and_and(conns) ++
#    M.x_y_output_to_xor_and_and(conns) ++
rejects =
  (M.z_output_from_xor(conns) ++
     M.internal_gates(conns) ++
     M.and_goes_to_or(conns) ++
     M.xor_chains(conns))
  |> Enum.uniq()
  |> Enum.map(fn {wire, _} -> wire end)
  |> Enum.sort()

IO.inspect(rejects |> Enum.join(","))
