defmodule BigchainExTest do
  use ExUnit.Case
  doctest BigchainEx

  test "greets the world" do
    assert BigchainEx.hello() == :world
  end
end
