defmodule JsonpathTest do
  use ExUnit.Case
  doctest Jsonpath

  alias Jsonpath.ParseError

  test "singly nested path" do
    assert Jsonpath.path(%{"fam" => "lit"}, "fam") == "lit"
  end

  test "doubly nested path" do
    assert Jsonpath.path(%{"fam" => %{"lit" => 1}}, "fam.lit") == 1
  end

  test "triply nested path" do
    assert Jsonpath.path(%{
      "fam" => %{
        "lit" => %{
          "bae" => "value"
        }
      }
    }, "fam.lit.bae") == "value"
  end

  test "partially fulfilling path" do
    assert Jsonpath.path(%{
      "fam" => %{
        "lit" => %{
          "bae" => "value"
        }
      }
    }, "fam.lit") == %{"bae" => "value"}
  end

  test "doubly nested path with trailing list, 0th index" do
    assert Jsonpath.path(%{
      "fam" => %{
        "lit" => [
          "coffee",
          "beer"
        ]
      }
    }, "fam.lit[0]") == "coffee"
  end

  test "doubly nested path with trailing list, 1st index" do
    assert Jsonpath.path(%{
      "fam" => %{
        "lit" => [
          "coffee",
          "beer"
        ]
      }
    }, "fam.lit[1]") == "beer"
  end

  test "doubly nested path with trailing list, out of bounds index" do
    assert Jsonpath.path(%{
      "fam" => %{
        "lit" => [
          "coffee",
          "beer"
        ]
      }
    }, "fam.lit[2]") == nil
  end

  test "doubly nested path with trailing list, invalid index" do
    assert_raise ParseError, "Invalid index 'xy' in token 'lit[xy]'", fn ->
      Jsonpath.path(%{
        "fam" => %{
          "lit" => [
            "coffee",
            "beer"
          ]
        }
      }, "fam.lit[xy]")
    end
  end

  test "doubly nested path with with list at 0th index, trailing single path" do
    assert Jsonpath.path(%{
      "fam" => %{
        "lit" => [
          %{"drink" => "coffee"},
          %{"drink" => "beer"}
        ]
      }
    }, "fam.lit[0].drink") == "coffee"
  end

  test "doubly nested path with with list at 0th index, expected trailing map" do
    assert_raise ParseError, "Expected map but instead got 1", fn ->
      Jsonpath.path(%{
        "fam" => %{
          "lit" => [
            1,
            2
          ]
        }
      }, "fam.lit[0].drink")
    end
  end

  test "triply nested path, expected trailing list" do
    assert_raise ParseError, "Expected list but instead got %{\"a\" => 1, \"b\" => 2}", fn ->
      Jsonpath.path(%{
        "fam" => %{
          "lit" => %{
            "a" => 1,
            "b" => 2
          }
        }
      }, "fam.lit[0]")
    end
  end
end
