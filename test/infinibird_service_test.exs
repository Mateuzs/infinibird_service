defmodule InfinibirdServiceTest do
  use ExUnit.Case
  doctest InfinibirdService

  test "greets the world" do
    assert InfinibirdService.hello() == :world
  end
end
