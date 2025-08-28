defmodule TrackerClient do
  @moduledoc """
    Get tracker response and store it
  """
  import Bitwise

  defstruct complete: 0, incomplete: 0, interval: 1800, peers: []

  defmodule Peers do
    defstruct ip: nil, port: nil, peer_id: nil
  end

  @port 6881
  @client_id ET
  @client_version 0001
  @peer_id_max_byte_size 20

  def announce(%Metainfo{} = metainfo) do
    with info_hash <- metainfo.info_hash_v1,
         total_size <- metainfo.info.piece_length,
         params <- build_tracker_params(info_hash, total_size),
         {:ok, response} <-
           Req.get(metainfo.announce,
             params: params,
             receive_timeout: 30_000,
             retry: :transient,
             max_retries: 3
           ),
         body <- Map.get(response, :body),
         {:ok, decoded_body, _} <- Bencode.decode(body),
         peer_binary = Map.get(decoded_body, "peers"),
         peers = parse_tracker_peers(peer_binary) do
      peers
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_tracker_peers(<<ip1, ip2, ip3, ip4, port_high, port_low, _rest::binary>> = bin)
       when is_binary(bin) do
    ip = {ip1, ip2, ip3, ip4}
    port = (port_high <<< 8) + port_low

    %Peers{
      ip: ip,
      port: port
    }
  end

  defp parse_tracker_peers(_) do
    {:error, "Peers not found"}
  end

  defp build_tracker_params(info_hash, total_size) do
    %{
      "info_hash" => info_hash,
      "peer_id" => generate_peer_id(),
      "port" => @port,
      "uploaded" => 0,
      "downloaded" => 0,
      "left" => total_size,
      "compact" => 1,
      "event" => "started"
    }
  end

  defp generate_peer_id() do
    prefix = "-#{@client_id}#{@client_version}-"

    sufix_length = @peer_id_max_byte_size - byte_size(prefix)

    random_sufix =
      :crypto.strong_rand_bytes(sufix_length) |> Base.encode16() |> String.slice(0, sufix_length)

    prefix <> random_sufix
  end
end
