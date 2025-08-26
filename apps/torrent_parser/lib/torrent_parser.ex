defmodule TorrentParser do
  @moduledoc """
  Documentation for `TorrentParser`.
  """

  def parse_file(torrent_path) do
    with {:ok, content} <- File.read(torrent_path),
         {:ok, decoded_map, _tail} <- Bencode.decode(content) do
      parse_decoded_map(decoded_map)
    else
      _ -> {:error, :enotent}
    end
  end

  defp parse_decoded_map(torrent_map) do
    info_map = torrent_map |> Map.get("info")

    {:ok, bencoded_info} = info_map |> Bencode.encode()
    info_hash_v1 = :crypto.hash(:sha, bencoded_info)

    %Metainfo{
      announce: Map.get(torrent_map, "announce"),
      announce_list: Map.get(torrent_map, "announce-list"),
      comment: Map.get(torrent_map, "comment"),
      created_by: Map.get(torrent_map, "created by"),
      creation_date: Map.get(torrent_map, "creation date"),
      info: parse_torrent_info(info_map),
      info_hash_v1: info_hash_v1
    }
  end

  defp parse_torrent_info(torrent_info) do
    %InfoDict{
      name: Map.get(torrent_info, "name"),
      length: Map.get(torrent_info, "length"),
      pieces: Map.get(torrent_info, "pieces"),
      piece_length: Map.get(torrent_info, "piece length")
    }
  end
end
