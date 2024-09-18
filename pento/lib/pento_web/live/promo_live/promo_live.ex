defmodule PentoWeb.PromoLive do
  use PentoWeb, :live_view

  alias Pento.Promo
  alias Pento.Promo.Recipient

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: recipient_form(), recipient: %Recipient{})}
  end

  def handle_event(
        "validate",
        %{"recipient" => recipient_params},
        %{assigns: %{recipient: recipient}} = socket
      ) do
    changeset = recipient_changeset(recipient, recipient_params)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"recipient" => recipient_params}, socket) do
    changeset = recipient_changeset(socket.assigns.recipient, recipient_params)

    if changeset.valid? do
      send_promo(socket, recipient_params)
    else
      {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp recipient_form() do
    %Recipient{}
    |> Recipient.changeset()
    |> to_form()
  end

  defp recipient_changeset(recipient, recipient_params) do
    recipient
    |> Promo.change_recipient(recipient_params)
    |> Map.put(:action, :validate)
  end

  defp send_promo(socket, changeset) do
    case Promo.send_email(changeset) do
      {:ok, recipient} ->
        {:noreply,
         socket
         |> assign(form: recipient_form())
         |> put_flash(:info, "Product updated successfully")}

      {:error, error} ->
        {:noreply,
         socket
         |> assign(form: changeset)
         |> put_flash(:error, "The promo could not be sent, error: #{error}")}
    end
  end
end
