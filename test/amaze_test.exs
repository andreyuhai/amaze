defmodule AmazeTest do
  use ExUnit.Case
  doctest Amaze

  test "greets the world" do
    assert Amaze.hello() == :world
  end
end
