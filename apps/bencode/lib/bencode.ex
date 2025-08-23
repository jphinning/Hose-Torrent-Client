defmodule Bencode do
  @moduledoc """
  Public interface for encoding and decoding bencode strings.
  """

  @doc """
  Decodes a bencoded string into Elixir terms.

  ## Examples

      iex> Bencode.decode("i42e")
      {:ok, 42, ""}

      iex> Bencode.decode("4:spam")
      {:ok, "spam", ""}

      iex> Bencode.decode("l4:spami42ee")
      {:ok, ["spam", 42], ""}

      iex> Bencode.decode("d3:cow3:moo4:spam4:eggse")
      {:ok, %{"cow" => "moo", "spam" => "eggs"}, ""}
  """
  def decode(bencode_str) do
    alias BencodeDecoding, as: Bd
    bencode_str |> Bd.parse_dispatcher()
  end

  @doc """
    Encodes Elixir terms into bencoded strings.

   ## Examples

      iex> Bencode.encode(42)
      {:ok, "i42e"}

      iex> Bencode.encode("spam")
      {:ok, "4:spam"}

      iex> Bencode.encode(["spam", 42])
      {:ok, "l4:spami42ee"}

      iex> Bencode.encode(%{"cow" => "moo", "spam" => "eggs"})
      {:ok, "d3:cow3:moo4:spam4:eggse"}

      iex> Bencode.encode(%{"info" => %{"length" => 1048576, "name" => "testfile.txt"}})
      {:ok, "d4:infod6:lengthi1048576e4:name12:testfile.txtee"}
  """
  def encode(bencode_str) do
    alias BencodeEncoding, as: Be
    bencode_str |> Be.parse_dispatcher()
  end
end
