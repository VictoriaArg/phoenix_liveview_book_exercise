defmodule PentoWeb.RatingLive.Show do
  use Phoenix.Component

  import PentoWeb.CoreComponents

  attr :rating, :any, required: true

  def stars(assigns) do
    ~H"""
    <div class="flex items-center justify-start">
      <%= for _star <- 1..@rating.stars do %>
        <.icon name="hero-star-solid" class="h-5 w-5 mr-4" />
      <% end %>
      <%= for _star <- Enum.take(1..5, (5 - @rating.stars)) do %>
        <.icon name="hero-star" class="h-5 w-5 mr-4" />
      <% end %>
    </div>
    """
  end
end
