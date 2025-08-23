defmodule BencodeTest do
  use ExUnit.Case
  doctest Bencode

  test "decodes integers" do
    assert Bencode.decode("i0e") == {:ok, 0, ""}
    assert Bencode.decode("i42e") == {:ok, 42, ""}
    assert Bencode.decode("i-42e") == {:ok, -42, ""}
  end

  test "rejects invalid integers" do
    assert {:error, _} = Bencode.decode("i-0e")
    assert {:error, _} = Bencode.decode("i03e")
  end

  test "decodes strings" do
    assert Bencode.decode("4:spam") == {:ok, "spam", ""}
  end

  test "decodes lists" do
    assert Bencode.decode("l4:spami42ee") == {:ok, ["spam", 42], ""}
  end

  test "decodes dictionaries" do
    assert Bencode.decode("d3:cow3:moo4:spam4:eggse") ==
             {:ok, %{"cow" => "moo", "spam" => "eggs"}, ""}
  end
end
