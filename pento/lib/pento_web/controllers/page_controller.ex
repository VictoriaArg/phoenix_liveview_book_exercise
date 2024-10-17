defmodule PentoWeb.PageController do
  use PentoWeb, :controller
  alias Phoenix.Controller

  def home(conn, _params) do
    if conn.assigns.current_user !== nil do
      render(conn, :home, layout: {PentoWeb.Layouts, :app})
    else
      render(conn, :home, layout: false)
    end
  end
end
