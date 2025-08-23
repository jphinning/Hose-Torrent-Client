defmodule Bencode do
  @moduledoc """
  Documentation for `Bencode`.
  """

  def decode(bencode_str) do
    alias BencodeDecoding, as: Bd
    bencode_str |> Bd.parse_dispatcher()
  end

  def encode(bencode_str) do
    bencode_str
  end
end
