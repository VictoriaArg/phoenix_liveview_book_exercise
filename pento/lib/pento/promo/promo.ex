defmodule Pento.Promo do
  alias Pento.Promo.Recipient

  def change_recipient(%Recipient{} = recipient, attrs \\ %{}) do
    Recipient.changeset(recipient, attrs)
  end

  def send_email(recipient) do
    # to do: send promo emails and authentication emails
    {:ok, recipient}
  end
end
