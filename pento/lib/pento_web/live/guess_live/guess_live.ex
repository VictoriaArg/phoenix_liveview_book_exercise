defmodule PentoWeb.GuessLive do
  use PentoWeb, :live_view

  @default_message "Make a guess:"
  @default_difficulty "easy"
  @tick_interval 1000

  def mount(_params, session, socket) do
    if connected?(socket), do: schedule_tick()
    number_range = define_number_range(@default_difficulty)

    mounted_socket =
      socket
      |> assign(score: 0)
      |> assign(message: @default_message)
      |> assign(time: time())
      |> assign(secret_number: Enum.random(number_range))
      |> assign(number_range: number_range)
      |> assign(winner?: false)
      |> assign(session_id: session["live_socket_id"])
      |> assign(form: to_form(%{"difficulty" => @default_difficulty}))

    {:ok, mounted_socket}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <p class="mb-4">It's <%= @time %></p>
    <.main_title>Guess game</.main_title>
    <p class="mt-2 text-[1.2rem] font-medium">Choose a difficulty and guess the secret number:</p>
    <p class="mt-2">Changing the difficulty changes the secret number</p>
    <div class="mb-12 w-48">
      <.simple_form for={@form} id="difficulty-form" phx-change="change_difficulty">
        <.input
          field={@form[:difficulty]}
          name={:difficulty}
          type="select"
          label="Difficulty"
          options={["easy", "intermediate", "hard"]}
        />
      </.simple_form>
    </div>

    <h1 class="text-[1.5rem] mb-4">Your score: <%= @score %></h1>
    <h2 class="text-[1.2rem] font-semibold mb-4">
      <%= @message %>
    </h2>
    <%= if !@winner? do %>
      <div class="md:flex md:w-auto w-48 grid grid-rows-3 grid-flow-col gap-4">
        <%= for n <- @number_range do %>
          <.button class="w-12 pt-1 mb-4" size="small" phx-click="guess" phx-value-number={n}>
            <%= n %>
          </.button>
        <% end %>
      </div>
    <% else %>
      <.button phx-click="play_again">Play again</.button>
    <% end %>
    """
  end

  def handle_event("guess", %{"number" => guess}, socket) do
    updated_socket =
      if String.to_integer(guess) !== socket.assigns.secret_number do
        wrong_guess_assigns(socket)
      else
        right_guess_assigns(socket)
      end

    {:noreply, assign(updated_socket, time: time())}
  end

  def handle_event("play_again", _, socket) do
    {:noreply, assign(socket, winner?: false, time: time(), message: @default_message)}
  end

  def handle_event("change_difficulty", %{"difficulty" => difficulty}, socket) do
    number_range = define_number_range(difficulty)

    {:noreply,
     socket
     |> assign(winner?: false)
     |> assign(time: time())
     |> assign(number_range: number_range)
     |> assign(secret_number: Enum.random(number_range))}
  end

  def handle_info(:tick, socket) do
    schedule_tick()
    {:noreply, assign(socket, :time, time())}
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_interval)
  end

  defp time() do
    DateTime.utc_now()
    |> Timex.format!("{h12}:{0m}:{0s} {AM}")
  end

  defp wrong_guess_assigns(socket) do
    score = socket.assigns.score - 1

    socket
    |> assign(score: score)
    |> assign(message: "Wrong, guess again.")
    |> assign(winner?: false)
  end

  defp right_guess_assigns(socket) do
    score = socket.assigns.score + 1

    socket
    |> assign(score: score)
    |> assign(message: "You guessed correctly, good job!")
    |> assign(winner?: true)
  end

  @spec define_number_range(String.t()) :: list()
  defp define_number_range("easy"), do: 1..3
  defp define_number_range("intermediate"), do: 1..6
  defp define_number_range("hard"), do: 1..9
end
