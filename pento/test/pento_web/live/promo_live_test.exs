defmodule PentoWeb.PromoLiveTest do
  use PentoWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Promo code" do
    setup [:register_and_log_in_user]

    test "promo codes are currently disabled", %{conn: conn} do
      {:ok, live, html} = live(conn, ~p"/promo")

      assert html =~ "Promo codes"
      assert html =~ "Promo codes are for 10% off their first game purchase!"

      assert live
             |> element("#recipient_first_name")
             |> render() =~ "disabled"

      assert live
             |> element("#recipient_email")
             |> render() =~ "disabled"

      assert live
             |> element("#send_promo")
             |> render() =~ "disabled"
    end
  end
end
