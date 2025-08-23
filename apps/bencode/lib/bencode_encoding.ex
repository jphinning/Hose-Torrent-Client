defmodule BencodeEncoding do
  def parse_dispatcher(bin_string) when is_binary(bin_string), do: parse_string(bin_string)
  def parse_dispatcher(number) when is_number(number), do: parse_integer(number)
  def parse_dispatcher(list) when is_list(list), do: parse_list(list)
  def parse_dispatcher(map) when is_map(map), do: parse_dictionary(map)
  def parse_dispatcher(_), do: {:error, :invalid}

  def parse_string(bin_string) when is_binary(bin_string) do
    {:ok, "#{byte_size(bin_string)}:#{bin_string}"}
  end

  def parse_string(_invalid_type) do
    {:error, :invalid}
  end

  def parse_integer(integer) when is_integer(integer) do
    {:ok, "i#{integer}e"}
  end

  def parse_integer(_invalid_type) do
    {:error, :invalid}
  end

  def parse_list(list) when is_list(list) do
    bencoded_string =
      Enum.reduce(list, "", fn item, acc ->
        {:ok, bencode} = parse_dispatcher(item)
        acc <> bencode
      end)

    {:ok, "l#{bencoded_string}e"}
  end

  def parse_list(_invalid_type) do
    {:error, :invalid}
  end

  def parse_dictionary(map) when is_map(map) do
    transformed_in_list = Enum.map(map, fn item -> item end)

    bencoded_string =
      Enum.reduce(transformed_in_list, "", fn item, acc ->
        {key, value} = item
        {:ok, parsed_key} = parse_dispatcher(key)
        {:ok, parsed_value} = parse_dispatcher(value)

        acc <> "#{parsed_key}#{parsed_value}"
      end)

    {:ok, "d#{bencoded_string}e"}
  end

  def parse_dictionary(_invalid_type) do
    {:error, :invalid}
  end
end
