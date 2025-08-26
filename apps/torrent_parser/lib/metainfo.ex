defmodule InfoDict do
  defstruct length: nil, name: nil, piece_length: nil, pieces: nil
end

defmodule Metainfo do
  defstruct announce: nil,
            announce_list: [],
            comment: nil,
            created_by: nil,
            creation_date: nil,
            info: %InfoDict{},
            info_hash_v1: nil
end
