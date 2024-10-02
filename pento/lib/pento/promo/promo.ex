defmodule Pento.Promo do
  alias Pento.Promo.Recipient

  @spec change_recipient(%Recipient{}, map()) :: Ecto.Changeset.t()
  def change_recipient(%Recipient{} = recipient, attrs \\ %{}) do
    Recipient.changeset(recipient, attrs)
  end

  @spec send_email(%Recipient{}) :: {:ok, %Recipient{}}
  def send_email(recipient) do
    # to do: send promo emails and authentication emails
    {:ok, recipient}
  end
end
