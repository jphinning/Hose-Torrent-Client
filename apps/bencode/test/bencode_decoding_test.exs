defmodule BencodeDecodingTest do
  use ExUnit.Case
  alias BencodeDecoding

  test "parse_integer/1" do
    assert BencodeDecoding.parse_integer("i42e") == {:ok, 42, ""}
    assert {:error, _} = BencodeDecoding.parse_integer("i-0e")
  end

  test "parse_string/1" do
    assert BencodeDecoding.parse_string("4:spam") == {:ok, "spam", ""}
  end
end
