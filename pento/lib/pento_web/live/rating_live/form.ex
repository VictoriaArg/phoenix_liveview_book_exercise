defmodule PentoWeb.RatingLive.Form do
  use PentoWeb, :live_component
  alias Pento.Survey
  alias Pento.Survey.Rating

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_rating()
     |> assign_changeset()}
  end

  def handle_event("validate", %{"rating" => rating_params}, socket) do
    {:noreply, validate_changeset(rating_params, socket)}
  end

  def handle_event("save", %{"rating" => rating_params}, socket) do
    {:noreply, save_rating(socket, rating_params)}
  end

  def assign_rating(%{assigns: %{current_user: user, product: product}} = socket) do
    assign(socket, :rating, %Rating{user_id: user.id, product_id: product.id})
  end

  def assign_changeset(%{assigns: %{rating: rating}} = socket) do
    changeset = Survey.change_rating(rating)

    socket
    |> assign(:form, to_form(changeset))
  end

  def save_rating(
        %{assigns: %{product_index: product_index, product: product}} = socket,
        rating_params
      ) do
    case Survey.create_rating(rating_params) do
      {:ok, rating} ->
        updated_product = %{product | ratings: [rating]}
        send(self(), {:created_rating, updated_product, product_index})
        socket

      {:error, %Ecto.Changeset{} = changeset} ->
        error_changeset(changeset, socket)
    end
  end

  def validate_changeset(params, %{assigns: %{current_user: user}} = socket) do
    changeset = Survey.change_rating(%Rating{user_id: user.id}, params)
    assign(socket, form: to_form(changeset))
  end

  defp error_changeset(changeset, socket) do
    socket
    |> assign(form: to_form(changeset))
  end
end
