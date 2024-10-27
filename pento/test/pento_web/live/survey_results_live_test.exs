defmodule PentoWeb.SurveyResultsLiveTest do
  use PentoWeb.ConnCase
  alias PentoWeb.SurveyResultsLive

  describe "Socket state" do
    setup [:create_user, :create_product, :create_socket, :register_and_log_in_user]

    setup %{user: user} do
      create_demographic(%{user_id: user.id, year_of_birth: 2012})
      %{user: user2} = create_user()
      create_demographic(%{user_id: user2.id, year_of_birth: 1950})
      [user2: user2]
    end

    test "no ratings exist", %{socket: socket} do
      socket = assigns_for_survey_results(socket)

      assert socket.assigns.products_with_average_ratings == [{"some name", 0}]
    end

    test "ratings exist", %{socket: socket, product: product, user: user} do
      create_rating(%{stars: 2, user_id: user.id, product_id: product.id})
      socket = assigns_for_survey_results(socket)

      assert socket.assigns.products_with_average_ratings == [{"some name", 2.0}]
    end

    test "ratings are filtered by age group", %{
      socket: socket,
      user: user,
      product: product,
      user2: user2
    } do
      create_rating(%{stars: 2, user_id: user.id, product_id: product.id})
      create_rating(%{stars: 3, user_id: user2.id, product_id: product.id})

      socket
      |> SurveyResultsLive.assign_age_group_filter()
      |> assert_keys(:age_group_filter, "all")
      |> SurveyResultsLive.assign_age_group_filter("18 and under")
      |> assert_keys(:age_group_filter, "18 and under")
      |> SurveyResultsLive.assign_gender_filter()
      |> SurveyResultsLive.assign_products_with_average_ratings()
      |> assert_keys(:products_with_average_ratings, [{"some name", 2.0}])
    end
  end

  defp assigns_for_survey_results(socket) do
    socket
    |> SurveyResultsLive.assign_age_group_filter()
    |> SurveyResultsLive.assign_gender_filter()
    |> SurveyResultsLive.assign_products_with_average_ratings()
  end
end
