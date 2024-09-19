defmodule Pento.Catalog.Search do
  defstruct [:search_value]
  @types %{search_value: :string}

  import Ecto.Changeset

  def changeset(%__MODULE__{} = search, attrs \\ %{}) do
    {search, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_length(:search_value, is: 7)
    |> Map.put(:action, :validate)
  end
end
