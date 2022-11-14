defmodule Amaze do
  @moduledoc """
  Documentation for `Amaze`.
  """

  @black 0.0
  @white 255.0

  def read do
    {:ok, tensor} =
      "/Users/burak/Downloads/2x2-maze.png"
      |> Image.open!()
      |> Image.split_bands()
      |> List.first()
      |> Image.to_nx()

    tensor = Nx.squeeze(tensor)
    {_width, height} = tensor.shape

    tensor
    |> Nx.to_flat_list()
    |> Enum.chunk_every(height)
    |> Matrex.new()
  end

  def draw(stck) do
    img =
      "/Users/burak/Downloads/2x2-maze.png"
      |> Image.open!()

    stck
    |> Enum.with_index()
    |> Enum.reduce(img, fn
      {{_x, _y}, 0}, acc ->
        acc

      {{x, y}, ind}, acc ->
        {x1, y1} = Enum.at(stck, ind - 1)

        {:ok, img} =
          Vix.Vips.Image.mutate(acc, fn mut_img ->
            Vix.Vips.MutableOperation.draw_line!(mut_img, [255, 0, 0, 255], x, y, x1, y1)
          end)

        img
    end)
  end

  def entrance(maze) do
    case Matrex.find(maze, @white) do
      {1, _} = entrance_node ->
        entrance_node

      _ ->
        raise "The entrance is not on the first row"
    end
  end

  def dfs(maze, stack \\ [], visit_map \\ %{})

  def dfs(maze, [] = _stack, visit_map) do
    start_node = entrance(maze)
    visit_map = Map.put(visit_map, start_node, true)
    stack = [start_node]

    if exit_found?(maze, stack) do
      IO.puts("Exit found!!!")
    else
      dfs(maze, stack, visit_map)
    end
  end

  def dfs(maze, [_current_node | rest] = stack, visit_map) do
    maze
    |> visitable_nodes(stack, visit_map)
    |> List.first()
    |> case do
      nil ->
        stack = rest
        dfs(maze, stack, visit_map)

      node_to_visit ->
        visit_map = Map.put(visit_map, node_to_visit, true)
        stack = [node_to_visit | stack]

        if exit_found?(maze, stack) do
          IO.puts("Exit found!!!!")
          stack
        else
          dfs(maze, stack, visit_map)
        end
    end
  end

  def exit_found?(maze, [{x, _y} | _rest] = _stack) do
    {rows, _cols} = Matrex.size(maze)

    x == rows
  end

  def visitable_nodes(maze, [{x, y} | _] = _stack, visit_map) do
    {x_max, y_max} = Matrex.size(maze)
    l = [{0, 1}, {0, -1}, {1, 0}]

    Enum.reduce(l, fn {x1, y1}, acc ->
      case {x1 + x, y1 + y} do
        {x2, y2} when x2 < 1 or y2 < 1 ->
          acc

        {x2, y2} when x2 > x_max or y2 > y_max ->
          acc

        {x2, y2} ->
          if visited?(visit_map, {x2, y2}), do: acc, else: [{x2, y2} | acc]
      end
    end)
  end

  def visited?(visit_map, node) do
    Map.get(visit_map, node, false)
  end

  def wall?(maze, {x, y}) do
    Matrex.at(maze, x, y) == @black
  end
end
