defmodule BencodeEncodingTest do
  use ExUnit.Case
  doctest BencodeEncoding

  describe "parse_dispatcher/1" do
    test "dispatches to parse_string for binaries" do
      assert BencodeEncoding.parse_dispatcher("test") == {:ok, "4:test"}
    end

    test "dispatches to parse_integer for numbers" do
      assert BencodeEncoding.parse_dispatcher(123) == {:ok, "i123e"}
    end

    test "dispatches to parse_list for lists" do
      assert BencodeEncoding.parse_dispatcher(["test"]) == {:ok, "l4:teste"}
    end

    test "dispatches to parse_dictionary for maps" do
      assert BencodeEncoding.parse_dispatcher(%{"key" => "value"}) == {:ok, "d3:key5:valuee"}
    end

    test "returns error for invalid types" do
      assert BencodeEncoding.parse_dispatcher(:atom) == {:error, :invalid}
    end
  end

  describe "parse_string/1" do
    test "encodes valid strings" do
      assert BencodeEncoding.parse_string("hello") == {:ok, "5:hello"}
    end

    test "encodes empty strings" do
      assert BencodeEncoding.parse_string("") == {:ok, "0:"}
    end

    test "returns error for non-binary input" do
      assert BencodeEncoding.parse_string(123) == {:error, :invalid}
    end
  end

  describe "parse_integer/1" do
    test "encodes positive integers" do
      assert BencodeEncoding.parse_integer(42) == {:ok, "i42e"}
    end

    test "encodes negative integers" do
      assert BencodeEncoding.parse_integer(-42) == {:ok, "i-42e"}
    end

    test "encodes zero" do
      assert BencodeEncoding.parse_integer(0) == {:ok, "i0e"}
    end

    test "returns error for non-integer input" do
      assert BencodeEncoding.parse_integer("string") == {:error, :invalid}
    end
  end

  describe "parse_list/1" do
    test "encodes empty lists" do
      assert BencodeEncoding.parse_list([]) == {:ok, "le"}
    end

    test "encodes lists with mixed types" do
      assert BencodeEncoding.parse_list(["spam", 42]) == {:ok, "l4:spami42ee"}
    end

    test "returns error for non-list input" do
      assert BencodeEncoding.parse_list("string") == {:error, :invalid}
    end
  end

  describe "parse_dictionary/1" do
    test "encodes empty maps" do
      assert BencodeEncoding.parse_dictionary(%{}) == {:ok, "de"}
    end

    test "encodes maps with string keys" do
      assert BencodeEncoding.parse_dictionary(%{"key" => "value"}) == {:ok, "d3:key5:valuee"}
    end

    test "encodes maps with nested structures" do
      input = %{"info" => %{"length" => 100}}
      assert BencodeEncoding.parse_dictionary(input) == {:ok, "d4:infod6:lengthi100eee"}
    end

    test "returns error for non-map input" do
      assert BencodeEncoding.parse_dictionary("string") == {:error, :invalid}
    end
  end
end
