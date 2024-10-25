defmodule PentoWeb.UserActivityLive do
  use PentoWeb, :live_component
  alias PentoWeb.Presence

  @user_activity_topic "user_activity"

  def update(_assigns, socket) do
    {:ok,
     socket
     |> assign_user_activity()}
  end

  def assign_user_activity(socket) do
    assign(socket, :user_activity, list_products_and_users())
  end

  def list_products_and_users() do
    Presence.list(@user_activity_topic)
    |> Enum.map(&extract_product_with_users/1)
  end

  defp extract_product_with_users({product_name, %{metas: metas}}) do
    {product_name, users_from_metas_list(metas)}
  end

  defp users_from_metas_list(metas_list) do
    Enum.map(metas_list, &users_from_meta_map/1)
    |> List.flatten()
    |> Enum.uniq()
  end

  def users_from_meta_map(meta_map) do
    get_in(meta_map, [:users])
  end
end
