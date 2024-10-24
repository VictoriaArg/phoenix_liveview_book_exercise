defmodule PentoWeb.PageControllerTest do
  use PentoWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 200) =~
             "Please remember this is just a demo application, for security reasons don't use your real information."
  end
end
