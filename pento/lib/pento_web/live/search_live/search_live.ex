defmodule PentoWeb.SearchLive do
  use PentoWeb, :live_view

  alias Pento.Catalog
  alias Pento.Catalog.Search

  def mount(_params, _session, socket) do
    mounted_socket =
      socket
      |> assign(search_value: nil)
      |> assign(product: nil)
      |> assign(form: to_form(Search.changeset(%Search{})))

    {:ok, mounted_socket}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} id="product-search" phx-change="search">
        <.input field={@form[:search_value]} type="text" label="Search by sku number" />
        <%= cond do %>
          <% @search_value == nil and @product == nil -> %>
            <p>You can search registered products by their SKU</p>
          <% @product == nil -> %>
            <p>No product found</p>
          <% @product !== nil -> %>
            <.header>
              Product <%= @product.id %>
              <:subtitle>This is a product record from your database.</:subtitle>
              <:actions>
                <.link patch={~p"/products/#{@product}/show/edit"} phx-click={JS.push_focus()}>
                  <.button>Edit product</.button>
                </.link>
              </:actions>
            </.header>

            <.list>
              <:item title="Name"><%= @product.name %></:item>
              <:item title="Description"><%= @product.description %></:item>
              <:item title="Unit price"><%= @product.unit_price %></:item>
              <:item title="Sku"><%= @product.sku %></:item>
            </.list>
            <%= if @product.image_upload do %>
              <div class="mt-8">
                <img class="rounded-xl" alt="product image" width="200" src={@product.image_upload} />
              </div>
            <% end %>
        <% end %>
      </.simple_form>
    </div>
    """
  end

  def handle_event("search", %{"search" => %{"search_value" => ""}}, socket),
    do: {:noreply, assign(socket, :search_value, nil)}

  def handle_event("search", %{"search" => %{"search_value" => value}}, socket) do
    changeset = Search.changeset(%Search{}, %{search_value: value})

    if changeset.valid? do
      %Search{search_value: value} = Ecto.Changeset.apply_changes(changeset)

      product_found = Catalog.search_product(value)

      updated_socket =
        socket
        |> assign(product: product_found)
        |> assign(search_value: value)
        |> assign(form: to_form(changeset))

      {:noreply, updated_socket}
    else
      {:noreply,
       socket
       |> assign(form: to_form(changeset))
       |> assign(product: nil)}
    end
  end
end
