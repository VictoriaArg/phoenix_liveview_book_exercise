defmodule PentoWeb.GuessLiveTest do
  use PentoWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "playing guess game" do
    setup [:register_and_log_in_user]

    test "initial score is 0, initial difficulty is easy", %{conn: conn} do
      {:ok, live, html} = live(conn, ~p"/guess")

      assert html =~ "Guess game"
      assert html =~ "Your score: 0"
      assert html =~ "<option selected=\"selected\" value=\"easy\">easy</option>"

      for n <- 1..3 do
        assert live
               |> element("button#button-#{n}")
               |> has_element?()
      end
    end

    test "playing on intermediate difficulty adds more options", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/guess")

      assert live
             |> element("form")
             |> render_change(%{"difficulty" => "intermediate"}) =~ "intermediate"

      for n <- 1..6 do
        assert live
               |> element("button#button-#{n}")
               |> has_element?()
      end
    end

    test "playing on hard difficulty adds even more options", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/guess")

      assert live
             |> element("form")
             |> render_change(%{"difficulty" => "hard"}) =~ "hard"

      for n <- 1..9 do
        assert live
               |> element("button#button-#{n}")
               |> has_element?()
      end
    end

    test "user makes a correct guess on an easy game", %{conn: conn} do
      {:ok, live, _html} = live(conn, "/guess")

      secret_number = get_secret_number(live)

      live = render_click(live, "guess", %{"number" => secret_number})

      assert live =~ "You guessed correctly, good job!"
      assert live =~ "Your score: 1"
    end

    test "user makes a wrong guess on an hard game, then guesses correctly in an easy game", %{
      conn: conn
    } do
      {:ok, live, _html} = live(conn, "/guess")

      live
      |> element("form")
      |> render_change(%{"difficulty" => "hard"})

      secret_number = get_secret_number(live)

      wrong_secret_number =
        1..9
        |> Enum.to_list()
        |> Enum.drop(String.to_integer(secret_number))
        |> Enum.random()

      rendered_view = render_click(live, "guess", %{"number" => to_string(wrong_secret_number)})

      assert rendered_view =~ "Wrong, guess again."
      assert rendered_view =~ "Your score: -1"

      live
      |> element("form")
      |> render_change(%{"difficulty" => "easy"})

      secret_number = get_secret_number(live)

      rendered_view = render_click(live, "guess", %{"number" => secret_number})

      assert rendered_view =~ "You guessed correctly, good job!"
      assert rendered_view =~ "Your score: 0"
    end
  end

  defp get_secret_number(live) do
    {:ok, [{_, [{"data-secret-number", secret_number}, _], []}]} =
      live
      |> element("[data-secret-number]")
      |> render()
      |> Floki.parse_document()

    secret_number
  end
end
