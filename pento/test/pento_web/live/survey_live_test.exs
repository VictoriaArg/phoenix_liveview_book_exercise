defmodule PentoWeb.SurveyLiveTest do
  use PentoWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Pento.Survey

  describe "demographic survey and product rating" do
    setup [:register_and_log_in_user, :create_product]

    test "renders the demographic survey form when user doesn't have a demographic", %{
      conn: conn
    } do
      {:ok, _live, html} = live(conn, ~p"/survey")

      assert html =~ "User survey"
      assert html =~ "Please fill out our survey"
      assert html =~ "demographic-form"
      assert html =~ "Save"
      refute html =~ "Demographics"
    end

    test "renders the demographic details after submitting the form", %{
      conn: conn,
      user: user
    } do
      {:ok, live, _html} = live(conn, ~p"/survey")

      form_data = %{
        "demographic" => %{
          "gender" => "female",
          "year_of_birth" => "1990",
          "education_level" => "highschool"
        }
      }

      assert live |> element("form#demographic-form") |> has_element?()

      live
      |> form("#demographic-form", form_data)
      |> render_submit()

      demographic = Survey.get_demographic_by_user(user)

      assert demographic.user_id == user.id
      assert demographic.gender == "female"
      assert demographic.year_of_birth == 1990
      assert demographic.education_level == "highschool"

      refute live |> element("form#demographic-form") |> has_element?()
    end

    test "displays the submitted product rating", %{conn: conn, user: user} do
      create_demographic(%{user_id: user.id})

      {:ok, live, _html} = live(conn, ~p"/survey")

      form_data = %{
        "rating" => %{
          "stars" => "5"
        }
      }

      assert live |> element("form") |> has_element?()

      live
      |> form("form", form_data)
      |> render_submit()

      refute live |> element("form") |> has_element?()

      rendered_view = render(live)

      assert rendered_view
             |> Floki.find("span.hero-star-solid")
             |> Enum.count() == 5
    end

    test "the heading changes when ratings for all the products were submitted", %{
      conn: conn,
      user: user,
      product: product
    } do
      create_demographic(%{user_id: user.id})
      %{product: product2} = create_product(name: "second product")

      form_data = %{
        "rating" => %{
          "stars" => "5"
        }
      }

      {:ok, live, _html} = live(conn, ~p"/survey")

      assert live |> element("form#rating-form-#{product.id}") |> has_element?()
      assert live |> element("form#rating-form-#{product2.id}") |> has_element?()

      live
      |> form("form#rating-form-#{product.id}", form_data)
      |> render_submit()

      rendered_view = render(live)

      assert rendered_view
             |> Floki.find("span.hero-star-solid")
             |> Enum.count() == 5

      refute live |> element("form#rating-form-#{product.id}") |> has_element?()
      assert live |> element("form#rating-form-#{product2.id}") |> has_element?()

      live
      |> form("form#rating-form-#{product2.id}", form_data)
      |> render_submit()

      rendered_view = render(live)

      assert rendered_view
             |> Floki.find("span.hero-star-solid")
             |> Enum.count() == 10

      refute live |> element("form#rating-form-#{product2.id}") |> has_element?()
      assert live |> element("p", "✓") |> has_element?()
    end
  end
end
