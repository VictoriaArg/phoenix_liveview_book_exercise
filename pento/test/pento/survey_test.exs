defmodule Pento.SurveyTest do
  use Pento.DataCase

  alias Pento.Survey

  import Pento.AccountsFixtures

  describe "demographics" do
    alias Pento.Survey.Demographic

    import Pento.{SurveyFixtures, AccountsFixtures}

    @invalid_attrs %{gender: nil, year_of_birth: nil}

    setup do
      %{demographic: demographic_fixture()}
    end

    test "list_demographics/0 returns all demographics", %{demographic: demographic} do
      assert Survey.list_demographics() == [demographic]
    end

    test "get_demographic!/1 returns the demographic with given id", %{demographic: demographic} do
      assert Survey.get_demographic!(demographic.id) == demographic
    end

    test "create_demographic/1 with valid data creates a demographic", %{demographic: demographic} do
      valid_attrs =
        demographic
        |> Map.from_struct()
        |> Map.replace(:user_id, user_fixture().id)

      assert {:ok, %Demographic{} = demographic} = Survey.create_demographic(valid_attrs)
      assert demographic.gender == demographic.gender
      assert demographic.year_of_birth == demographic.year_of_birth
    end

    test "create_demographic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Survey.create_demographic(@invalid_attrs)
    end

    test "update_demographic/2 with valid data updates the demographic", %{
      demographic: demographic
    } do
      update_attrs = %{gender: "male", year_of_birth: 1999}

      assert {:ok, %Demographic{} = demographic} =
               Survey.update_demographic(demographic, update_attrs)

      assert demographic.gender == "male"
      assert demographic.year_of_birth == 1999
    end

    test "update_demographic/2 with invalid data returns error changeset", %{
      demographic: demographic
    } do
      assert {:error, %Ecto.Changeset{}} = Survey.update_demographic(demographic, @invalid_attrs)
      assert demographic == Survey.get_demographic!(demographic.id)
    end

    test "delete_demographic/1 deletes the demographic", %{demographic: demographic} do
      assert {:ok, %Demographic{}} = Survey.delete_demographic(demographic)
      assert_raise Ecto.NoResultsError, fn -> Survey.get_demographic!(demographic.id) end
    end

    test "change_demographic/1 returns a demographic changeset", %{demographic: demographic} do
      assert %Ecto.Changeset{} = Survey.change_demographic(demographic)
    end
  end

  describe "ratings" do
    alias Pento.Survey.Rating

    import Pento.SurveyFixtures

    @invalid_attrs %{stars: nil}

    setup do
      %{rating: rating_fixture()}
    end

    test "list_ratings/0 returns all ratings", %{rating: rating} do
      assert Survey.list_ratings() == [rating]
    end

    test "get_rating!/1 returns the rating with given id", %{rating: rating} do
      assert Survey.get_rating!(rating.id) == rating
    end

    test "create_rating/1 with valid data creates a rating", %{rating: rating} do
      valid_attrs =
        rating
        |> Map.from_struct()
        |> Map.replace(:user_id, user_fixture().id)

      assert {:ok, %Rating{} = rating} = Survey.create_rating(valid_attrs)
      assert rating.stars == 4
    end

    test "create_rating/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Survey.create_rating(@invalid_attrs)
    end

    test "update_rating/2 with valid data updates the rating", %{rating: rating} do
      update_attrs = %{stars: 4}

      assert {:ok, %Rating{} = rating} = Survey.update_rating(rating, update_attrs)
      assert rating.stars == 4
    end

    test "update_rating/2 with invalid data returns error changeset", %{rating: rating} do
      assert {:error, %Ecto.Changeset{}} = Survey.update_rating(rating, @invalid_attrs)
      assert rating == Survey.get_rating!(rating.id)
    end

    test "delete_rating/1 deletes the rating", %{rating: rating} do
      assert {:ok, %Rating{}} = Survey.delete_rating(rating)
      assert_raise Ecto.NoResultsError, fn -> Survey.get_rating!(rating.id) end
    end

    test "change_rating/1 returns a rating changeset", %{rating: rating} do
      assert %Ecto.Changeset{} = Survey.change_rating(rating)
    end
  end
end
