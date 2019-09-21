defmodule Budget.Controllers.UserControllerTest do
  use BudgetWeb.ConnCase, async: true

  test "create" do
    conn = build_conn()

    response =
      conn
      |> post(
        Routes.user_path(conn, :create, %{
          "first_name" => "Michael",
          "last_name" => "St Clair",
          "email" => "michaelst57@gmail.com",
          "password" => "password"
        })
      )
      |> json_response(200)

    assert %{
             "email" => "michaelst57@gmail.com",
             "first_name" => "Michael",
             "last_name" => "St Clair"
           } == Map.take(response, ["email", "first_name", "last_name"])

    assert Map.keys(response) == ["email", "first_name", "id", "last_name", "token"]
  end

  test "required validation" do
    conn = build_conn()

    response =
      conn
      |> post(Routes.user_path(conn, :create, %{}))
      |> json_response(422)

    assert response == %{
             "errors" => %{"email" => ["can't be blank"], "password" => ["can't be blank"]},
             "status" => "failure"
           }
  end

  test "unique validation" do
    conn = build_conn()

    conn
    |> post(
      Routes.user_path(conn, :create, %{
        "email" => "michaelst57@gmail.com",
        "password" => "password"
      })
    )
    |> json_response(200)

    response =
      conn
      |> post(
        Routes.user_path(conn, :create, %{
          "email" => "michaelst57@gmail.com",
          "password" => "password"
        })
      )
      |> json_response(422)

    assert response == %{"status" => "failure", "errors" => %{"email" => ["has already been taken"]}}
  end
end
