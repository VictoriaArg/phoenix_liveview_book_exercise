defmodule PentoWeb.GuessLive do
  use PentoWeb, :live_view

  @default_message "Make a guess:"
  @tick_interval 1000

  def mount(_params, session, socket) do
    if connected?(socket), do: schedule_tick()

    mounted_socket =
      socket
      |> assign(score: 0)
      |> assign(message: @default_message)
      |> assign(time: time())
      |> assign(secret_number: Enum.random(1..10))
      |> assign(winner?: false)
      |> assign(session_id: session["live_socket_id"])

    {:ok, mounted_socket}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <p>It's <%= @time %></p>
    <h1>Your score: <%= @score %></h1>
    <h2>
      <%= @message %>
    </h2>
    <h2>
      <%= if !@winner? do %>
        <%= for n <- 1..10 do %>
          <.link href="#" phx-click="guess" phx-value-number={n}>
            <%= n %>
          </.link>
        <% end %>
      <% else %>
        <.button phx-click="play_again">Play again</.button>
      <% end %>
    </h2>
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
    |> assign(message: "Wrong, guess again. Your score is #{score}. ")
    |> assign(winner?: false)
  end

  defp right_guess_assigns(socket) do
    score = socket.assigns.score + 1

    socket
    |> assign(score: score)
    |> assign(message: "You guessed correctly, good job! Your score is #{score}. ")
    |> assign(winner?: true)
  end
end
