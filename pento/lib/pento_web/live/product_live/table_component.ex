defmodule PentoWeb.ProductLive.TableComponent do
  use PentoWeb, :live_component

  alias Pento.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @products.inserts !== [] do %>
        <.table
          id="products"
          rows={@products}
          row_click={fn {_id, product} -> JS.navigate(~p"/products/#{product}") end}
        >
          <:col :let={{_id, product}} label="Name"><%= product.name %></:col>
          <:col :let={{_id, product}} label="Description"><%= product.description %></:col>
          <:col :let={{_id, product}} label="Unit price"><%= product.unit_price %></:col>
          <:col :let={{_id, product}} label="Sku"><%= product.sku %></:col>
          <:action :let={{_id, product}}>
            <div class="sr-only">
              <.link navigate={~p"/products/#{product}"}>Show</.link>
            </div>
            <.link patch={~p"/products/#{product}/edit"}>Edit</.link>
          </:action>
          <:action :let={{id, product}}>
            <.link
              phx-click={JS.push("delete", value: %{id: product.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          </:action>
        </.table>
      <% else %>
        <div class="h-48 w-full flex items-center justify-center">
          <p class="font-semibold">No products found</p>
        </div>
      <% end %>
    </div>
    """
  end
end
