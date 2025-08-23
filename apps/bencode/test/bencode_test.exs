defmodule BencodeTest do
  use ExUnit.Case
  doctest Bencode

  describe "decode/1" do
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
      assert Bencode.decode("14:spamisn'tagood") == {:ok, "spamisn'tagood", ""}
    end

    test "decodes lists" do
      assert Bencode.decode("l4:spami42ee") == {:ok, ["spam", 42], ""}
    end

    test "decodes dictionaries" do
      assert Bencode.decode("d3:cow3:moo4:spam4:eggse") ==
               {:ok, %{"cow" => "moo", "spam" => "eggs"}, ""}
    end
  end

  describe "encode/1" do
    test "encodes integers" do
      assert Bencode.encode(42) == {:ok, "i42e"}
    end

    test "encodes strings" do
      assert Bencode.encode("spam") == {:ok, "4:spam"}
    end

    test "encodes lists" do
      assert Bencode.encode(["spam", 42]) == {:ok, "l4:spami42ee"}
    end

    test "encodes dictionaries" do
      assert Bencode.encode(%{"cow" => "moo", "spam" => "eggs"}) ==
               {:ok, "d3:cow3:moo4:spam4:eggse"}
    end

    test "encodes nested structures" do
      input = %{"info" => %{"length" => 1_048_576, "name" => "testfile.txt"}}
      expected = {:ok, "d4:infod6:lengthi1048576e4:name12:testfile.txtee"}
      assert Bencode.encode(input) == expected
    end
  end
end
