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
end
