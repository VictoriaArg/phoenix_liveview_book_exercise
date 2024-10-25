defmodule PentoWeb.SurveyResultsLiveTest do
  use PentoWeb.ConnCase
  alias PentoWeb.SurveyResultsLive

  describe "Socket state" do
    setup [:create_user, :create_product, :create_socket, :register_and_log_in_user]

    setup %{user: user} do
      create_demographic(user)
      user2 = user_fixture(create_user2_attrs())
      demographic_fixture(user2, create_demographic_attrs())
      [user2: user2]
    end

    test "no ratings exist", %{socket: socket} do
      socket = assigns_for_survey_results(socket)

      assert socket.assigns.products_with_average_ratings == [{"Test Game", 0}]
    end

    test "ratings exist", %{socket: socket, product: product, user: user} do
      create_rating(2, user, product)
      socket = assigns_for_survey_results(socket)

      assert socket.assigns.products_with_average_ratings == [{"Test Game", 2.0}]
    end

    test "ratings are filtered by age group", %{
      socket: socket,
      user: user,
      product: product,
      user2: user2
    } do
      create_rating(2, user, product)
      create_rating(3, user2, product)

      socket
      |> SurveyResultsLive.assign_age_group_filter()
      |> assert_keys(:age_group_filter, "all")
      |> SurveyResultsLive.assign_age_group_filter("18 and under")
      |> assert_keys(:age_group_filter, "18 and under")
      |> SurveyResultsLive.assign_gender_filter()
      |> SurveyResultsLive.assign_products_with_average_ratings()
      |> assert_keys(:products_with_average_ratings, [{"Test Game", 2.5}])
    end
  end

  defp assigns_for_survey_results(socket) do
    socket
    |> SurveyResultsLive.assign_age_group_filter()
    |> SurveyResultsLive.assign_gender_filter()
    |> SurveyResultsLive.assign_products_with_average_ratings()
  end
end
