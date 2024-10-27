defmodule PentoWeb.DashboardLiveTest do
  use PentoWeb.ConnCase
  import Phoenix.LiveViewTest

  setup [:register_and_log_in_user, :create_product, :create_user]

  setup %{user: user, product: product} do
    create_rating(%{stars: 2, user_id: user.id, product_id: product.id})

    %{user: user2} = create_user()
    create_demographic(%{user_id: user2.id, year_of_birth: 1950})
    create_rating(%{stars: 3, user_id: user2.id, product_id: product.id})

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

    %{user: user3} = create_user()

    create_demographic(%{user_id: user3.id, year_of_birth: 1978})

    create_rating(%{stars: 5, user_id: user3.id, product_id: product.id})
    send(view.pid, %{event: "rating_created"})
    :timer.sleep(2)

    assert render(view) =~ "<title>3.33</title>"
  end
end
