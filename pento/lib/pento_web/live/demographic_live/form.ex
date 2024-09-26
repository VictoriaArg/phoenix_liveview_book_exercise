defmodule PentoWeb.DemographicLive.Form do
  use PentoWeb, :live_component

  alias Pento.Survey
  alias Pento.Survey.Demographic

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    updated_socket =
      socket
      |> assign(assigns)
      |> assign_demographic()
      |> assign_changeset()

    {:ok, updated_socket}
  end

  def handle_event("save", %{"demographic" => demographic_params}, socket) do
    params = params_with_user_id(demographic_params, socket)
    changeset = Demographic.changeset(%Demographic{}, params)

    if changeset.valid? do
      save_demographic(socket, params)
    else
      {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_info({:created_demographic, demographic}, socket) do
    {:noreply, handle_demographic_created(socket, demographic)}
  end

  def params_with_user_id(params, %{assigns: %{current_user: current_user}}) do
    params
    |> Map.put("user_id", current_user.id)
  end

  def save_demographic(socket, params) do
    case Survey.create_demographic(params) do
      {:ok, demographic} ->
        send(self(), {:created_demographic, demographic})
        socket

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, form: to_form(changeset))
    end
  end

  def handle_demographic_created(socket, demographic) do
    socket
    |> put_flash(:info, "Demographic created successfully")
    |> assign(:demographic, demographic)
  end

  defp assign_demographic(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, :demographic, %Demographic{user_id: current_user.id})
  end

  defp assign_changeset(%{assigns: %{demographic: demographic}} = socket) do
    changeset = Demographic.changeset(%Demographic{}, demographic)
    assign(socket, :form, to_form(changeset))
  end
end
