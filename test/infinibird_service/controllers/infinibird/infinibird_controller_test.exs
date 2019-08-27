defmodule InfinibirdService.InfinibirdControllerTest do
  use ExUnit.Case
  alias InfinibirdService.InfinibirdController

  test "get rides data" do
    expected = [
      ride0: %{
        acceleration_amount: 1,
        deceleration_amount: 0,
        distance_meters: 138,
        end_time: "2019-07-27 11:43:46",
        left_turns_amount: 0,
        max_speed: 1.0155469,
        name: "2019-07-27 11:21:36",
        points: [
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:21:36"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:21:51"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:22:07"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:22:22"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:22:38"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:22:53"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:23:09"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:23:24"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:23:40"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:23:55"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:24:11"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:24:27"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:24:42"
          ],
          [
            lat: 50.79674166666667,
            lon: 20.456811666666667,
            alt: 290.5,
            mps: 0.0,
            tim: "11:24:57"
          ],
          [
            lat: 50.797140000000006,
            lon: 20.457318333333333,
            alt: 392.4,
            mps: 0.0,
            tim: "11:41:24"
          ],
          [
            lat: 50.79660166666666,
            lon: 20.457033333333335,
            alt: 309.9,
            mps: 0.0,
            tim: "11:41:33"
          ],
          [
            lat: 50.79662666666666,
            lon: 20.457026666666664,
            alt: 309.8,
            mps: 0.0,
            tim: "11:41:35"
          ],
          [lat: 50.79662, lon: 20.457013333333336, alt: 295.2, mps: 0.0, tim: "11:41:51"],
          [
            lat: 50.79661333333333,
            lon: 20.457015000000002,
            alt: 295.3,
            mps: 0.0,
            tim: "11:42:07"
          ],
          [
            lat: 50.79661333333333,
            lon: 20.457015000000002,
            alt: 295.3,
            mps: 0.0,
            tim: "11:42:23"
          ],
          [
            lat: 50.79661333333333,
            lon: 20.457015000000002,
            alt: 295.3,
            mps: 0.0,
            tim: "11:42:39"
          ],
          [
            lat: 50.79661333333333,
            lon: 20.457015000000002,
            alt: 295.3,
            mps: 0.0,
            tim: "11:42:54"
          ],
          [
            lat: 50.79661333333333,
            lon: 20.457015000000002,
            alt: 295.3,
            mps: 0.0,
            tim: "11:43:09"
          ],
          [
            lat: 50.79661333333333,
            lon: 20.457015000000002,
            alt: 295.3,
            mps: 0.0,
            tim: "11:43:25"
          ],
          [lat: 50.796594999999996, lon: 20.45696, alt: 292.2, mps: 0.0, tim: "11:43:33"],
          [
            lat: 50.79657999999999,
            lon: 20.456928333333334,
            alt: 292.3,
            mps: 0.0,
            tim: "11:43:35"
          ],
          [
            lat: 50.79657333333333,
            lon: 20.456911666666667,
            alt: 292.6,
            mps: 0.0,
            tim: "11:43:43"
          ],
          [
            lat: 50.796609999999994,
            lon: 20.456868333333333,
            alt: 292.7,
            mps: 1.0155469,
            tim: "11:43:44"
          ]
        ],
        right_turns_amount: 0,
        start_time: "2019-07-27 11:21:36",
        stoppings_amount: 0,
        travel_time_minutes: 22
      }
    ]

    assert assert InfinibirdController.get_rides_data("test-folder") === expected
  end
end