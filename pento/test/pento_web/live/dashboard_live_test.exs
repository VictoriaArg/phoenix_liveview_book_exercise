defmodule PentoWeb.DashboardLiveTest do
  use PentoWeb.ConnCase
  import Phoenix.LiveViewTest

  setup [:register_and_log_in_user, :create_product, :create_user]

  setup %{user: user, product: product} do
    create_demographic(user)
    create_rating(2, user, product)

    user2 =
      create_user2_attrs()
      |> user_fixture()

    user2
    |> demographic_fixture(create_demographic_over_18_attrs())

    create_rating(3, user2, product)

    :ok
  end

  test "it filters by age group", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/dashboard")

    params = %{"age_group_filter" => "18 and under"}

    view
    |> element("#age_group_form")
    |> render_change(params) =~ "<title>2.00</title>"
  end

  test "it updates to display newly created ratings", %{conn: conn, product: product} do
    {:ok, view, html} = live(conn, "/dashboard")

    assert html =~ "<title>2.50</title>"

    user3 =
      create_user3_attrs()
      |> user_fixture()

    create_demographic(user3)
    create_rating(5, user3, product)
    send(view.pid, %{event: "rating_created"})
    :timer.sleep(2)

    assert render(view) =~ "<title>3.33</title>"
  end
end
