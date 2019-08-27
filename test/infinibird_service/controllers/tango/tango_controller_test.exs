defmodule InfinibirdService.TangoControllerTest do
  use ExUnit.Case
  alias InfinibirdService.TangoController

  test "generate new token from last characters" do
    assert TangoController.handle_new_trip("9bac2143-3f85-44f6-ad56-b575549af9e4") === "549af9e4"
  end

  test "generate random token when last characters duplicate" do
    assert TangoController.handle_new_trip("9bac2143-3f85-44f6-ad56-b5757e8a31fa") !== "7e8a31fa"
  end
end
