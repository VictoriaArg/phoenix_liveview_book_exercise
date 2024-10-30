defmodule PentoWeb.ProductLive.Index do
  use PentoWeb, :live_view

  alias Pento.Catalog
  alias Pento.Catalog.Product
  alias Pento.Catalog.Search

  @impl true
  def mount(_params, _session, socket) do
    updated_socket =
      socket
      |> assign(form: to_form(Search.changeset(%Search{})))
      |> stream(:products, Catalog.list_products())

    {:ok, updated_socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Catalog.get_product!(id)
    {:ok, _} = Catalog.delete_product(product)

    {:noreply, stream(socket, :products, Catalog.list_products())}
  end

  def handle_event("search", %{"search" => %{"search_value" => ""}}, socket),
    do:
      {:noreply,
       socket
       |> stream(:products, Catalog.list_products(), reset: true)}

  def handle_event("search", %{"search" => %{"search_value" => value}}, socket) do
    changeset = Search.changeset(%Search{}, %{search_value: value})

    if changeset.valid? do
      %Search{search_value: value} = Ecto.Changeset.apply_changes(changeset)

      updated_socket =
        socket
        |> assign(form: to_form(changeset))
        |> stream(:products, find_product(value), reset: true)

      {:noreply, updated_socket}
    else
      {:noreply,
       socket
       |> assign(form: to_form(changeset))}
    end
  end

  @impl true
  def handle_info({PentoWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Catalog.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  defp find_product(value) do
    product_found = Catalog.search_product(value)

    if product_found == nil do
      []
    else
      [product_found]
    end
  end
end
