defmodule HomePageTest do
  use PhoenixTest.Playwright.Case

  use BazarWeb, :verified_routes

  test "in browser", %{conn: conn} do
    conn
    |> visit(~p"/")
    |> evaluate("console.log('Hey')")
  end
end
