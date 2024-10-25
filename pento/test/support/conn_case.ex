defmodule PentoWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use PentoWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate
  alias Pento.{Accounts, Survey, Catalog}

  using do
    quote do
      # The default endpoint for testing
      @endpoint PentoWeb.Endpoint

      use PentoWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import PentoWeb.ConnCase
    end
  end

  setup tags do
    Pento.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = Pento.AccountsFixtures.user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Pento.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  def create_product(_), do: %{product: product_fixture()}
  def create_user(_), do: %{user: user_fixture()}
  def create_rating(stars, user, product), do: %{rating: rating_fixture(stars, user, product)}
  def create_demographic(user), do: %{demographic: demographic_fixture(user)}
  def create_socket(_), do: %{socket: %Phoenix.LiveView.Socket{}}

  def assert_keys(socket, key, value) do
    assert socket.assigns[key] == value
    socket
  end

  def product_fixture() do
    {:ok, product} = Catalog.create_product(create_product_attrs())
    product
  end

  def user_fixture(attrs \\ create_user_attrs()) do
    {:ok, user} = Accounts.register_user(attrs)
    user
  end

  def demographic_fixture(user, attrs \\ create_demographic_attrs()) do
    attrs =
      attrs
      |> Map.merge(%{user_id: user.id})

    {:ok, demographic} = Survey.create_demographic(attrs)
    demographic
  end

  def rating_fixture(stars, user, product) do
    {:ok, rating} =
      Survey.create_rating(%{
        stars: stars,
        user_id: user.id,
        product_id: product.id
      })

    rating
  end

  def create_product_attrs() do
    %{
      description: "test description",
      name: "Test Game",
      sku: "4242420",
      unit_price: 120.5
    }
  end

  def create_user_attrs() do
    %{
      email: "test@test.com",
      password: "passwordpassword"
    }
  end

  def create_user2_attrs() do
    %{
      email: "another_person@test.com",
      password: "passwordpassword"
    }
  end

  def create_user3_attrs() do
    %{
      email: "third_user@test.com",
      password: "passwordpassword"
    }
  end

  def create_demographic_over_18_attrs() do
    %{
      gender: "male",
      year_of_birth: DateTime.utc_now().year - 30,
      education_level: "graduate degree"
    }
  end

  def create_demographic_attrs() do
    %{
      gender: "female",
      year_of_birth: DateTime.utc_now().year - 15,
      education_level: "bachelor's degree"
    }
  end
end
