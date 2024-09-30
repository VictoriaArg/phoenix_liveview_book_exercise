defmodule Pento.Survey.Demographic do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pento.Accounts.User

  schema "demographics" do
    field :gender, :string
    field :year_of_birth, :integer
    field :education_level, :string
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @required_attrs [:gender, :year_of_birth, :education_level, :user_id]

  @doc false
  def changeset(demographic, attrs) do
    demographic
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:gender, gender_options())
    |> validate_inclusion(:year_of_birth, 1900..2024)
    |> validate_inclusion(:education_level, education_level_options())
    |> unique_constraint(:user_id)
  end

  def gender_options(), do: ["male", "female", "other", "prefer not to say"]

  def age_group_options(), do: ["all", "18 and under", "18 to 25", "25 to 35", "35 and up"]

  def education_level_options(),
    do: ["highschool", "bachelor's degree", "graduate degree", "other", "prefer not to say"]
end
