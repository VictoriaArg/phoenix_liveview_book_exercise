defmodule PentoWeb.RatingLive.Index do
  use Phoenix.Component
  alias PentoWeb.RatingLive

  attr :products, :list, required: true
  attr :current_user, :any, required: true

  def product_list(assigns) do
    ~H"""
    <.heading products={@products} />
    <div class="grid divide-y gap-4">
      <.product_rating
        :for={{p, i} <- Enum.with_index(@products)}
        current_user={@current_user}
        product={p}
        index={i}
      />
    </div>
    """
  end

  attr :products, :list, required: true

  def heading(assigns) do
    ~H"""
    <h2 class="font-medium text-xl mb-2">
      Products rating <p class="inline text-info-500"><%= if ratings_complete?(@products), do: "✓" %></p>
    </h2>
    """
  end

  attr :product, :any, required: true
  attr :current_user, :any, required: true
  attr :index, :integer, required: true

  def product_rating(assigns) do
    ~H"""
    <div class="py-4">
      <div class="mb-4"><%= @product.name %></div>
      <%= if rating = List.first(@product.ratings) do %>
        <RatingLive.Show.stars rating={rating} />
      <% else %>
        <.live_component
          module={RatingLive.Form}
          id={"rating-form-#{@product.id}"}
          product={@product}
          product_index={@index}
          current_user={@current_user}
        />
      <% end %>
    </div>
    """
  end

  defp ratings_complete?(products) do
    Enum.all?(products, fn product ->
      not Enum.empty?(product.ratings)
    end)
  end
end
