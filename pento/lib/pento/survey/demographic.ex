defmodule Pento.Survey.Demographic do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pento.Accounts.User

  schema "demographics" do
    field :gender, :string
    field :year_of_birth, :integer
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @required_attrs [:gender, :year_of_birth, :user_id]

  @doc false
  def changeset(demographic, attrs) do
    demographic
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:gender, ["male", "female", "other", "prefer not to say"])
    |> validate_inclusion(:year_of_birth, 1900..2024)
    |> unique_constraint(:user_id)
  end
end