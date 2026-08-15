defmodule SpendableWeb.CoreComponentsTest do
  use ExUnit.Case, async: true

  alias SpendableWeb.CoreComponents

  test "translates a changeset error" do
    assert CoreComponents.translate_error({"can't be blank", []}) == "can't be blank"
  end

  # Ecto hands length errors back with a count, and the message reads as a plural without it.
  test "translates a changeset error that carries a count" do
    assert CoreComponents.translate_error({"should be at most %{count} character(s)", count: 5}) ==
             "should be at most 5 character(s)"
  end
end
