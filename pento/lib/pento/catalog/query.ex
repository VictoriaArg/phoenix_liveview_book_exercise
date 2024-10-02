defmodule Pento.Catalog.Product.Query do
  import Ecto.Query

  alias Pento.Accounts.User
  alias Pento.Catalog.Product
  alias Pento.Survey.Demographic
  alias Pento.Survey.Rating

  def base, do: Product

  def search_by_sku_query(value) do
    from p in Pento.Catalog.Product,
      where: p.sku == ^value
  end

  def with_user_ratings(user) do
    base()
    |> preload_user_ratings(user)
  end

  def preload_user_ratings(query, user) do
    ratings_query = Rating.Query.preload_user(user)

    query
    |> preload(ratings: ^ratings_query)
  end

  def with_average_ratings(query \\ base()) do
    query
    |> join_ratings
    |> average_ratings
  end

  def join_users(query \\ base()) do
    query
    |> join(:left, [p, r], u in User, on: r.user_id == u.id)
  end

  def join_demographics(query \\ base()) do
    query
    |> join(:left, [p, r, u, d], d in Demographic, on: d.user_id == u.id)
  end

  def filter_by_age_group(query \\ base(), filter) do
    query
    |> apply_age_group_filter(filter)
  end

  def filter_by_gender(query \\ base(), filter) do
    query
    |> apply_gender_filter(filter)
  end

  def with_zero_ratings(query \\ base()) do
    query
    |> select([p], {p.name, 0})
  end

  defp join_ratings(query) do
    query
    |> join(:inner, [p], r in Rating, on: r.product_id == p.id)
  end

  defp average_ratings(query) do
    query
    |> group_by([p], p.id)
    |> select([p, r], {p.name, fragment("?::float", avg(r.stars))})
  end

  defp apply_age_group_filter(query, "18 and under") do
    birth_year = current_year() - 18

    query
    |> where([p, r, u, d], d.year_of_birth >= ^birth_year)
  end

  defp apply_age_group_filter(query, "18 to 25") do
    birth_year_max = current_year() - 25
    birth_year_min = current_year() - 35

    query
    |> where(
      [p, r, u, d],
      d.year_of_birth >= ^birth_year_min and d.year_of_birth <= ^birth_year_max
    )
  end

  defp apply_age_group_filter(query, "35 and up") do
    birth_year = current_year() - 35

    query
    |> where([p, r, u, d], d.year_of_birth <= ^birth_year)
  end

  defp apply_age_group_filter(query, _filter), do: query

  defp current_year do
    %DateTime{year: year} = DateTime.utc_now()

    year
  end

  defp apply_gender_filter(query, "all"), do: query

  defp apply_gender_filter(query, filter) do
    query
    |> where([p, r, u, d], d.gender == ^filter)
  end
end
