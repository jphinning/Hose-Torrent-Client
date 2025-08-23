defmodule BencodeDecoding do
  # Dispatch string to be parsed by the correct function
  def parse_dispatcher(<<digit, _::binary>> = bin_string) when digit in ?0..?9,
    do: parse_string(bin_string)

  def parse_dispatcher(<<?i, _::binary>> = bin_string), do: parse_integer(bin_string)
  def parse_dispatcher(<<?l, _::binary>> = bin_string), do: parse_list(bin_string)
  def parse_dispatcher(<<?d, _::binary>> = bin_string), do: parse_dictionary(bin_string)
  def parse_dispatcher(_), do: {:error, :invalid}

  def parse_string(bin_string) do
    with {index, 1} <- :binary.match(bin_string, ":"),
         <<len_bin::binary-size(index), ?:, string::binary>> <- bin_string,
         {len, _} <- Integer.parse(len_bin),
         <<parsed_string::binary-size(len), tail::binary>> <- string do
      {:ok, parsed_string, tail}
    else
      :nomatch -> {:error, :nomatch}
      _ -> {:error, :invalid}
    end
  end

  def parse_integer(<<?i, rest::binary>>) do
    with {idx, _} <- rest |> :binary.match("e"),
         <<number_bin::binary-size(idx), ?e, tail::binary>> <- rest,
         :ok <- validate_integer(number_bin),
         {number, _} <- Integer.parse(number_bin) do
      {:ok, number, tail}
    else
      :nomatch -> {:error, :nomatch}
      {:error, reason} -> {:error, reason}
      _ -> {:error, :invalid}
    end
  end

  defp validate_integer(<<?0>>), do: :ok

  defp validate_integer(number_bin) do
    cond do
      String.starts_with?(number_bin, "-0") ->
        {:error, "Can't start with -0"}

      String.starts_with?(number_bin, "0") ->
        {:error, "Can't start with 0"}

      true ->
        :ok
    end
  end

  def parse_list(<<?l, rest::binary>>), do: do_parse_list(rest, [])

  defp do_parse_list(<<?e, tail::binary>>, acc), do: {:ok, Enum.reverse(acc), tail}

  defp do_parse_list(bin_string, acc) do
    with {:ok, string, tail} <- bin_string |> parse_dispatcher() do
      do_parse_list(tail, [string | acc])
    else
      _ -> {:error, :invalid}
    end
  end

  def parse_dictionary(<<?d, rest::binary>>), do: do_parse_dictionary(rest, %{})

  defp do_parse_dictionary(<<?e, tail::binary>>, acc), do: {:ok, acc, tail}

  defp do_parse_dictionary(bin_string, acc) do
    with {:ok, key, tail} <- parse_string(bin_string),
         {:ok, value, tail} <- parse_dispatcher(tail) do
      do_parse_dictionary(tail, Map.put(acc, key, value))
    else
      _ -> {:error, :invalid}
    end
  end
end
