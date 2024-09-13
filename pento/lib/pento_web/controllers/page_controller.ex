defmodule PentoWeb.PageController do
  use PentoWeb, :controller
  alias Phoenix.Controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    if conn.assigns.current_user !== nil do
      Controller.redirect(conn, to: ~p"/guess")
    else
      render(conn, :home, layout: false)
    end
  end
end
