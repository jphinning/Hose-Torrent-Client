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

  def encode(bencode_str) do
    bencode_str
  end
end
