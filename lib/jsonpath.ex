defmodule Jsonpath do
  alias Jsonpath.ParseError

  def path(map, path) do
    tokens = String.split(path, ".")
    Enum.reduce(tokens, map, &handle_token/2)
  end

  def handle_token(token, node) do
    case Regex.run(~r/.*\[(.+)\]/, token) do
      [_, index_str] ->
        [key | _] = String.split(token, "[")
        index = parse_int(index_str, token)

        node
        |> Map.get(key)
        |> handle_list(index)

      nil ->
        handle_map(node, token)
    end
  end

  def handle_map(map, key) when is_map(map) do
    Map.get(map, key)
  end
  def handle_map(node, _) do
    raise ParseError, "Expected map but instead got #{inspect node}"
  end

  def handle_list(list, index) when is_list(list) do
    Enum.at(list, index)
  end
  def handle_list(node, _) do
    raise ParseError, "Expected list but instead got #{inspect node}"
  end

  defp parse_int(integer_str, token) do
    case Integer.parse(integer_str) do
      {int, _} ->
        int
      :error ->
        raise ParseError, "Invalid index '#{integer_str}' in token '#{token}'"
    end
  end
end

