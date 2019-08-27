defmodule InfinibirdService.RideDataExtractorsTest do
  use ExUnit.Case
  alias InfinibirdService.RideDataExtractors

  test "extract start time" do
    ride_sample = [
      %{
        "maneuverType" => "rideEvent",
        "timeRange" => %{
          "beginning" => "2019-07-25T19:05:20.247+02:00",
          "end" => "2019-07-25T19:05:20.247+02:00"
        },
        "rideEvent" => "START",
        "version" => 1
      }
    ]

    assert RideDataExtractors.extract_start_time(ride_sample) === "2019-07-25 19:05:20"
  end

  test "extract end time" do
    ride_sample = [
      %{
        "maneuverType" => "rideEvent",
        "timeRange" => %{
          "beginning" => "2019-07-25T19:05:20.247+02:00",
          "end" => "2019-07-25T19:40:20.247+02:00"
        },
        "rideEvent" => "START",
        "version" => 1
      }
    ]

    assert RideDataExtractors.extract_end_time(ride_sample) === "2019-07-25 19:40:20"
  end

  test "extract travel points" do
    ride_sample = [
      %{
        "accelerationDurationInS" => 3.001,
        "decelerationDurationInS" => 5.998,
        "maneuverType" => "accelerationFollowedByDeceleration",
        "timeRange" => %{
          "beginning" => "2019-07-26T10:34:55.465+02:00",
          "end" => "2019-07-26T10:35:04.464+02:00"
        },
        "version" => 1
      },
      %{
        "beginningGpsPosition" => %{
          "altitude" => 245.0,
          "bearingAccuracy" => 0.0,
          "bearingInDeg" => 358.3,
          "horizontalAccuracy" => 3.0,
          "latitude" => 50.03814847,
          "locationFixTimeInMs" => 1_564_130_098_000,
          "longitude" => 19.92568574,
          "numberOfSatellites" => 8,
          "speedAccuracy" => 0.0,
          "speedInMps" => 21.040154,
          "timestamp" => "2019-07-26T10:34:58.466+02:00",
          "verticalAccuracy" => 0.0
        },
        "beginningSpeedInMps" => 21.04015350341797,
        "endGpsPosition" => %{
          "altitude" => 245.0,
          "bearingAccuracy" => 0.0,
          "bearingInDeg" => 338.9,
          "horizontalAccuracy" => 3.0,
          "latitude" => 50.0391758,
          "locationFixTimeInMs" => 1_564_130_104_000,
          "longitude" => 19.92531909,
          "numberOfSatellites" => 8,
          "speedAccuracy" => 0.0,
          "speedInMps" => 19.33001,
          "timestamp" => "2019-07-26T10:35:04.464+02:00",
          "verticalAccuracy" => 0.0
        },
        "endSpeedInMps" => 19.33000946044922,
        "maneuverType" => "deceleration",
        "maxSpeedInMps" => 21.04015350341797,
        "minSpeedInMps" => 19.04094886779785,
        "timeRange" => %{
          "beginning" => "2019-07-26T10:34:58.466+02:00",
          "end" => "2019-07-26T10:35:04.464+02:00"
        },
        "version" => 2
      },
      %{
        "accelerationDurationInS" => 2.0,
        "decelerationDurationInS" => 5.998,
        "maneuverType" => "decelerationFollowedByAcceleration",
        "timeRange" => %{
          "beginning" => "2019-07-26T10:34:58.466+02:00",
          "end" => "2019-07-26T10:35:06.464+02:00"
        },
        "version" => 1
      },
      %{
        "beginningGpsPosition" => %{
          "altitude" => 245.0,
          "bearingAccuracy" => 0.0,
          "bearingInDeg" => 338.9,
          "horizontalAccuracy" => 3.0,
          "latitude" => 50.0391758,
          "locationFixTimeInMs" => 1_564_130_104_000,
          "longitude" => 19.92531909,
          "numberOfSatellites" => 8,
          "speedAccuracy" => 0.0,
          "speedInMps" => 19.33001,
          "timestamp" => "2019-07-26T10:35:04.464+02:00",
          "verticalAccuracy" => 0.0
        },
        "beginningSpeedInMps" => 19.33000946044922,
        "endGpsPosition" => %{
          "altitude" => 245.0,
          "bearingAccuracy" => 0.0,
          "bearingInDeg" => 338.4,
          "horizontalAccuracy" => 3.0,
          "latitude" => 50.03951277,
          "locationFixTimeInMs" => 1_564_130_106_000,
          "longitude" => 19.92510927,
          "numberOfSatellites" => 8,
          "speedAccuracy" => 0.0,
          "speedInMps" => 20.12001,
          "timestamp" => "2019-07-26T10:35:06.464+02:00",
          "verticalAccuracy" => 0.0
        },
        "endSpeedInMps" => 20.120010375976563,
        "maneuverType" => "acceleration",
        "maxSpeedInMps" => 20.120010375976563,
        "minSpeedInMps" => 19.33000946044922,
        "timeRange" => %{
          "beginning" => "2019-07-26T10:35:04.464+02:00",
          "end" => "2019-07-26T10:35:06.464+02:00"
        },
        "version" => 2
      }
    ]

    expected = [
      [
        lat: 50.03814847,
        lon: 19.92568574,
        alt: 245.0,
        mps: 21.040154,
        tim: "10:34:58"
      ],
      [lat: 50.0391758, lon: 19.92531909, alt: 245.0, mps: 19.33001, tim: "10:35:04"]
    ]

    assert RideDataExtractors.extract_travel_points(ride_sample) === expected
  end

  test "count distance" do
    points = [
      [
        lat: 50.03814847,
        lon: 19.92568574,
        alt: 245.0,
        mps: 21.040154,
        tim: "10:34:58"
      ],
      [lat: 50.0391758, lon: 19.92531909, alt: 245.0, mps: 19.33001, tim: "10:35:04"]
    ]

    assert RideDataExtractors.count_distance_meters(points) === 117
  end

  test "count travel time" do
    ride_sample = [
      %{
        "accelerationDurationInS" => 3.001,
        "decelerationDurationInS" => 5.998,
        "maneuverType" => "accelerationFollowedByDeceleration",
        "timeRange" => %{
          "beginning" => "2019-07-26T09:34:55.465+02:00",
          "end" => "2019-07-26T09:35:04.464+02:00"
        },
        "version" => 1
      },
      %{
        "beginningGpsPosition" => %{
          "altitude" => 245.0,
          "bearingAccuracy" => 0.0,
          "bearingInDeg" => 358.3,
          "horizontalAccuracy" => 3.0,
          "latitude" => 50.03814847,
          "locationFixTimeInMs" => 1_564_130_098_000,
          "longitude" => 19.92568574,
          "numberOfSatellites" => 8,
          "speedAccuracy" => 0.0,
          "speedInMps" => 21.040154,
          "timestamp" => "2019-07-26T10:34:58.466+02:00",
          "verticalAccuracy" => 0.0
        },
        "beginningSpeedInMps" => 21.04015350341797,
        "endGpsPosition" => %{
          "altitude" => 245.0,
          "bearingAccuracy" => 0.0,
          "bearingInDeg" => 338.9,
          "horizontalAccuracy" => 3.0,
          "latitude" => 50.0391758,
          "locationFixTimeInMs" => 1_564_130_104_000,
          "longitude" => 19.92531909,
          "numberOfSatellites" => 8,
          "speedAccuracy" => 0.0,
          "speedInMps" => 19.33001,
          "timestamp" => "2019-07-26T10:35:04.464+02:00",
          "verticalAccuracy" => 0.0
        },
        "endSpeedInMps" => 19.33000946044922,
        "maneuverType" => "deceleration",
        "maxSpeedInMps" => 21.04015350341797,
        "minSpeedInMps" => 19.04094886779785,
        "timeRange" => %{
          "beginning" => "2019-07-26T10:34:58.466+02:00",
          "end" => "2019-07-26T10:35:04.464+02:00"
        },
        "version" => 2
      },
      %{
        "accelerationDurationInS" => 2.0,
        "decelerationDurationInS" => 5.998,
        "maneuverType" => "decelerationFollowedByAcceleration",
        "timeRange" => %{
          "beginning" => "2019-07-26T10:34:58.466+02:00",
          "end" => "2019-07-26T10:35:06.464+02:00"
        },
        "version" => 1
      },
      %{
        "beginningGpsPosition" => %{
          "altitude" => 245.0,
          "bearingAccuracy" => 0.0,
          "bearingInDeg" => 338.9,
          "horizontalAccuracy" => 3.0,
          "latitude" => 50.0391758,
          "locationFixTimeInMs" => 1_564_130_104_000,
          "longitude" => 19.92531909,
          "numberOfSatellites" => 8,
          "speedAccuracy" => 0.0,
          "speedInMps" => 19.33001,
          "timestamp" => "2019-07-26T10:35:04.464+02:00",
          "verticalAccuracy" => 0.0
        },
        "beginningSpeedInMps" => 19.33000946044922,
        "endGpsPosition" => %{
          "altitude" => 245.0,
          "bearingAccuracy" => 0.0,
          "bearingInDeg" => 338.4,
          "horizontalAccuracy" => 3.0,
          "latitude" => 50.03951277,
          "locationFixTimeInMs" => 1_564_130_106_000,
          "longitude" => 19.92510927,
          "numberOfSatellites" => 8,
          "speedAccuracy" => 0.0,
          "speedInMps" => 20.12001,
          "timestamp" => "2019-07-26T10:35:06.464+02:00",
          "verticalAccuracy" => 0.0
        },
        "endSpeedInMps" => 20.120010375976563,
        "maneuverType" => "acceleration",
        "maxSpeedInMps" => 20.120010375976563,
        "minSpeedInMps" => 19.33000946044922,
        "timeRange" => %{
          "beginning" => "2019-07-26T10:35:04.464+02:00",
          "end" => "2019-07-26T10:35:06.464+02:00"
        },
        "version" => 2
      }
    ]

    assert RideDataExtractors.count_travel_time_minutes(ride_sample) === 60
  end

  test "count decelerations" do
    ride_sample = [
      %{
        "beginningGpsPosition" => %{
          "altitude" => 245.0,
          "bearingAccuracy" => 0.0,
          "bearingInDeg" => 358.3,
          "horizontalAccuracy" => 3.0,
          "latitude" => 50.03814847,
          "locationFixTimeInMs" => 1_564_130_098_000,
          "longitude" => 19.92568574,
          "numberOfSatellites" => 8,
          "speedAccuracy" => 0.0,
          "speedInMps" => 21.040154,
          "timestamp" => "2019-07-26T10:34:58.466+02:00",
          "verticalAccuracy" => 0.0
        },
        "beginningSpeedInMps" => 21.04015350341797,
        "endGpsPosition" => %{
          "altitude" => 245.0,
          "bearingAccuracy" => 0.0,
          "bearingInDeg" => 338.9,
          "horizontalAccuracy" => 3.0,
          "latitude" => 50.0391758,
          "locationFixTimeInMs" => 1_564_130_104_000,
          "longitude" => 19.92531909,
          "numberOfSatellites" => 8,
          "speedAccuracy" => 0.0,
          "speedInMps" => 19.33001,
          "timestamp" => "2019-07-26T10:35:04.464+02:00",
          "verticalAccuracy" => 0.0
        },
        "endSpeedInMps" => 19.33000946044922,
        "maneuverType" => "deceleration",
        "maxSpeedInMps" => 21.04015350341797,
        "minSpeedInMps" => 19.04094886779785,
        "timeRange" => %{
          "beginning" => "2019-07-26T10:34:58.466+02:00",
          "end" => "2019-07-26T10:35:04.464+02:00"
        },
        "version" => 2
      },
      %{
        "accelerationDurationInS" => 2.0,
        "decelerationDurationInS" => 5.998,
        "maneuverType" => "deceleration",
        "timeRange" => %{
          "beginning" => "2019-07-26T10:34:58.466+02:00",
          "end" => "2019-07-26T10:35:06.464+02:00"
        },
        "version" => 1
      },
      %{
        "beginningGpsPosition" => %{
          "altitude" => 245.0,
          "bearingAccuracy" => 0.0,
          "bearingInDeg" => 338.9,
          "horizontalAccuracy" => 3.0,
          "latitude" => 50.0391758,
          "locationFixTimeInMs" => 1_564_130_104_000,
          "longitude" => 19.92531909,
          "numberOfSatellites" => 8,
          "speedAccuracy" => 0.0,
          "speedInMps" => 19.33001,
          "timestamp" => "2019-07-26T10:35:04.464+02:00",
          "verticalAccuracy" => 0.0
        },
        "beginningSpeedInMps" => 19.33000946044922,
        "endGpsPosition" => %{
          "altitude" => 245.0,
          "bearingAccuracy" => 0.0,
          "bearingInDeg" => 338.4,
          "horizontalAccuracy" => 3.0,
          "latitude" => 50.03951277,
          "locationFixTimeInMs" => 1_564_130_106_000,
          "longitude" => 19.92510927,
          "numberOfSatellites" => 8,
          "speedAccuracy" => 0.0,
          "speedInMps" => 20.12001,
          "timestamp" => "2019-07-26T10:35:06.464+02:00",
          "verticalAccuracy" => 0.0
        },
        "endSpeedInMps" => 20.120010375976563,
        "maneuverType" => "acceleration",
        "maxSpeedInMps" => 20.120010375976563,
        "minSpeedInMps" => 19.33000946044922,
        "timeRange" => %{
          "beginning" => "2019-07-26T10:35:04.464+02:00",
          "end" => "2019-07-26T10:35:06.464+02:00"
        },
        "version" => 2
      }
    ]

    assert(RideDataExtractors.count_decelerations(ride_sample) === 2)
  end

  test "count accelerations" do
    ride_sample =
      ride_sample = [
        %{
          "beginningGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 358.3,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.03814847,
            "locationFixTimeInMs" => 1_564_130_098_000,
            "longitude" => 19.92568574,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 21.040154,
            "timestamp" => "2019-07-26T10:34:58.466+02:00",
            "verticalAccuracy" => 0.0
          },
          "beginningSpeedInMps" => 21.04015350341797,
          "endGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.9,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.0391758,
            "locationFixTimeInMs" => 1_564_130_104_000,
            "longitude" => 19.92531909,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 19.33001,
            "timestamp" => "2019-07-26T10:35:04.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "endSpeedInMps" => 19.33000946044922,
          "maneuverType" => "acceleration",
          "maxSpeedInMps" => 21.04015350341797,
          "minSpeedInMps" => 19.04094886779785,
          "timeRange" => %{
            "beginning" => "2019-07-26T10:34:58.466+02:00",
            "end" => "2019-07-26T10:35:04.464+02:00"
          },
          "version" => 2
        },
        %{
          "beginningGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.9,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.0391758,
            "locationFixTimeInMs" => 1_564_130_104_000,
            "longitude" => 19.92531909,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 19.33001,
            "timestamp" => "2019-07-26T10:35:04.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "beginningSpeedInMps" => 19.33000946044922,
          "endGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.4,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.03951277,
            "locationFixTimeInMs" => 1_564_130_106_000,
            "longitude" => 19.92510927,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 20.12001,
            "timestamp" => "2019-07-26T10:35:06.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "endSpeedInMps" => 20.120010375976563,
          "maneuverType" => "accelerationFollowedByDeceleration",
          "maxSpeedInMps" => 20.120010375976563,
          "minSpeedInMps" => 19.33000946044922,
          "timeRange" => %{
            "beginning" => "2019-07-26T10:35:04.464+02:00",
            "end" => "2019-07-26T10:35:06.464+02:00"
          },
          "version" => 2
        }
      ]

    assert RideDataExtractors.count_accelerations(ride_sample) === 2
  end

  test "count stoppings" do
    ride_sample =
      ride_sample = [
        %{
          "beginningGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 358.3,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.03814847,
            "locationFixTimeInMs" => 1_564_130_098_000,
            "longitude" => 19.92568574,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 21.040154,
            "timestamp" => "2019-07-26T10:34:58.466+02:00",
            "verticalAccuracy" => 0.0
          },
          "beginningSpeedInMps" => 21.04015350341797,
          "endGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.9,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.0391758,
            "locationFixTimeInMs" => 1_564_130_104_000,
            "longitude" => 19.92531909,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 19.33001,
            "timestamp" => "2019-07-26T10:35:04.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "endSpeedInMps" => 19.33000946044922,
          "maneuverType" => "acceleration",
          "maxSpeedInMps" => 21.04015350341797,
          "minSpeedInMps" => 19.04094886779785,
          "timeRange" => %{
            "beginning" => "2019-07-26T10:34:58.466+02:00",
            "end" => "2019-07-26T10:35:04.464+02:00"
          },
          "version" => 2
        },
        %{
          "beginningGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.9,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.0391758,
            "locationFixTimeInMs" => 1_564_130_104_000,
            "longitude" => 19.92531909,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 19.33001,
            "timestamp" => "2019-07-26T10:35:04.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "beginningSpeedInMps" => 19.33000946044922,
          "endGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.4,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.03951277,
            "locationFixTimeInMs" => 1_564_130_106_000,
            "longitude" => 19.92510927,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 20.12001,
            "timestamp" => "2019-07-26T10:35:06.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "endSpeedInMps" => 20.120010375976563,
          "maneuverType" => "stopping",
          "maxSpeedInMps" => 20.120010375976563,
          "minSpeedInMps" => 19.33000946044922,
          "timeRange" => %{
            "beginning" => "2019-07-26T10:35:04.464+02:00",
            "end" => "2019-07-26T10:35:06.464+02:00"
          },
          "version" => 2
        }
      ]

    assert RideDataExtractors.count_stoppings(ride_sample) === 1
  end

  test "count left turns" do
    ride_sample =
      ride_sample = [
        %{
          "beginningGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 358.3,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.03814847,
            "locationFixTimeInMs" => 1_564_130_098_000,
            "longitude" => 19.92568574,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 21.040154,
            "timestamp" => "2019-07-26T10:34:58.466+02:00",
            "verticalAccuracy" => 0.0
          },
          "beginningSpeedInMps" => 21.04015350341797,
          "endGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.9,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.0391758,
            "locationFixTimeInMs" => 1_564_130_104_000,
            "longitude" => 19.92531909,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 19.33001,
            "timestamp" => "2019-07-26T10:35:04.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "endSpeedInMps" => 19.33000946044922,
          "maneuverType" => "leftTurn",
          "maxSpeedInMps" => 21.04015350341797,
          "minSpeedInMps" => 19.04094886779785,
          "timeRange" => %{
            "beginning" => "2019-07-26T10:34:58.466+02:00",
            "end" => "2019-07-26T10:35:04.464+02:00"
          },
          "version" => 2
        },
        %{
          "beginningGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.9,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.0391758,
            "locationFixTimeInMs" => 1_564_130_104_000,
            "longitude" => 19.92531909,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 19.33001,
            "timestamp" => "2019-07-26T10:35:04.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "beginningSpeedInMps" => 19.33000946044922,
          "endGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.4,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.03951277,
            "locationFixTimeInMs" => 1_564_130_106_000,
            "longitude" => 19.92510927,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 20.12001,
            "timestamp" => "2019-07-26T10:35:06.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "endSpeedInMps" => 20.120010375976563,
          "maneuverType" => "leftTurn",
          "maxSpeedInMps" => 20.120010375976563,
          "minSpeedInMps" => 19.33000946044922,
          "timeRange" => %{
            "beginning" => "2019-07-26T10:35:04.464+02:00",
            "end" => "2019-07-26T10:35:06.464+02:00"
          },
          "version" => 2
        }
      ]

    assert RideDataExtractors.count_left_turns(ride_sample) === 2
  end

  test "count rigt turns" do
    ride_sample =
      ride_sample = [
        %{
          "beginningGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 358.3,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.03814847,
            "locationFixTimeInMs" => 1_564_130_098_000,
            "longitude" => 19.92568574,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 21.040154,
            "timestamp" => "2019-07-26T10:34:58.466+02:00",
            "verticalAccuracy" => 0.0
          },
          "beginningSpeedInMps" => 21.04015350341797,
          "endGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.9,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.0391758,
            "locationFixTimeInMs" => 1_564_130_104_000,
            "longitude" => 19.92531909,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 19.33001,
            "timestamp" => "2019-07-26T10:35:04.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "endSpeedInMps" => 19.33000946044922,
          "maneuverType" => "rightTurn",
          "maxSpeedInMps" => 21.04015350341797,
          "minSpeedInMps" => 19.04094886779785,
          "timeRange" => %{
            "beginning" => "2019-07-26T10:34:58.466+02:00",
            "end" => "2019-07-26T10:35:04.464+02:00"
          },
          "version" => 2
        },
        %{
          "beginningGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.9,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.0391758,
            "locationFixTimeInMs" => 1_564_130_104_000,
            "longitude" => 19.92531909,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 19.33001,
            "timestamp" => "2019-07-26T10:35:04.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "beginningSpeedInMps" => 19.33000946044922,
          "endGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.4,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.03951277,
            "locationFixTimeInMs" => 1_564_130_106_000,
            "longitude" => 19.92510927,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 20.12001,
            "timestamp" => "2019-07-26T10:35:06.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "endSpeedInMps" => 20.120010375976563,
          "maneuverType" => "rightTurn",
          "maxSpeedInMps" => 20.120010375976563,
          "minSpeedInMps" => 19.33000946044922,
          "timeRange" => %{
            "beginning" => "2019-07-26T10:35:04.464+02:00",
            "end" => "2019-07-26T10:35:06.464+02:00"
          },
          "version" => 2
        }
      ]

    assert RideDataExtractors.count_right_turns(ride_sample) === 2
  end

  test "find max speed" do
    ride_sample =
      ride_sample = [
        %{
          "beginningGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 358.3,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.03814847,
            "locationFixTimeInMs" => 1_564_130_098_000,
            "longitude" => 19.92568574,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 21.040154,
            "timestamp" => "2019-07-26T10:34:58.466+02:00",
            "verticalAccuracy" => 0.0
          },
          "beginningSpeedInMps" => 21.04015350341797,
          "endGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.9,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.0391758,
            "locationFixTimeInMs" => 1_564_130_104_000,
            "longitude" => 19.92531909,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 19.33001,
            "timestamp" => "2019-07-26T10:35:04.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "endSpeedInMps" => 19.33000946044922,
          "maneuverType" => "acceleration",
          "maxSpeedInMps" => 21.04015350341797,
          "minSpeedInMps" => 19.04094886779785,
          "timeRange" => %{
            "beginning" => "2019-07-26T10:34:58.466+02:00",
            "end" => "2019-07-26T10:35:04.464+02:00"
          },
          "version" => 2
        },
        %{
          "beginningGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.9,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.0391758,
            "locationFixTimeInMs" => 1_564_130_104_000,
            "longitude" => 19.92531909,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 19.33001,
            "timestamp" => "2019-07-26T10:35:04.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "beginningSpeedInMps" => 19.33000946044922,
          "endGpsPosition" => %{
            "altitude" => 245.0,
            "bearingAccuracy" => 0.0,
            "bearingInDeg" => 338.4,
            "horizontalAccuracy" => 3.0,
            "latitude" => 50.03951277,
            "locationFixTimeInMs" => 1_564_130_106_000,
            "longitude" => 19.92510927,
            "numberOfSatellites" => 8,
            "speedAccuracy" => 0.0,
            "speedInMps" => 20.12001,
            "timestamp" => "2019-07-26T10:35:06.464+02:00",
            "verticalAccuracy" => 0.0
          },
          "endSpeedInMps" => 20.120010375976563,
          "maneuverType" => "accelerationFollowedByDeceleration",
          "maxSpeedInMps" => 20.120010375976563,
          "minSpeedInMps" => 19.33000946044922,
          "timeRange" => %{
            "beginning" => "2019-07-26T10:35:04.464+02:00",
            "end" => "2019-07-26T10:35:06.464+02:00"
          },
          "version" => 2
        }
      ]

    assert RideDataExtractors.find_max_speed(ride_sample) === 21.040154
  end
end
