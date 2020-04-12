defmodule LiveTriviaWeb.DisplayLive do
  use Phoenix.LiveView

  alias LiveTrivia.GameSupervisor

  def render(assigns) do
    ~L"""
    <%= case @state do %>
      <% :welcome -> %>
        <%= live_component @socket, LiveTriviaWeb.DisplayLive.WelcomeComponent, players: @players, server: @server %>

      <% {:loading, message} -> %>
        <%= live_component @socket, LiveTriviaWeb.DisplayLive.LoadingComponent, message: message %>

      <% :render_multiple -> %>
        <%= live_component @socket, LiveTriviaWeb.DisplayLive.MultipleComponent, show_solution: @show_solution, question: @question, time: @time, locked_in: @locked_in %>

      <% :display_scores -> %>
        <%= live_component @socket, LiveTriviaWeb.DisplayLive.ScoreComponent, scores: @scores, game_over: false %>

      <% :game_over -> %>
        <%= live_component @socket, LiveTriviaWeb.DisplayLive.ScoreComponent, scores: @scores, game_over: true %>
    <% end %>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    GameSupervisor.start_child(id)

    LiveTriviaWeb.Endpoint.subscribe("games:" <> id)

    {:ok, init_socket(socket, id)}
  end

  def handle_event("start", _params, socket) do
    LiveTrivia.Game.start_game(socket.assigns.server)
    {:noreply, socket}
  end

  def handle_info(:update_players, socket) do
    players =
      LiveTriviaWeb.Presence.list("players:" <> socket.assigns[:server])
      |> Map.keys()

    {:noreply, assign(socket, :players, players)}
  end

  def handle_info({:loading, msg}, socket) do
    {:noreply, assign(socket, :state, {:loading, msg})}
  end

  def handle_info({:display_question, question, time}, socket) do
    socket =
      socket
      |> assign(:state, :render_multiple)
      |> assign(:question, question)
      |> assign(:show_solution, false)
      |> assign(:locked_in, [])
      |> assign(:time, time)

    {:noreply, socket}
  end

  def handle_info({:locked_in, players}, socket) do
    {:noreply, assign(socket, :locked_in, players)}
  end

  def handle_info({:tick, time}, socket) do
    {:noreply, assign(socket, :time, time)}
  end

  def handle_info(:display_answer, socket) do
    {:noreply, assign(socket, :show_solution, true)}
  end

  def handle_info({:display_scores, scores}, socket) do
    socket =
      socket
      |> assign(:state, :display_scores)
      |> assign(:scores, scores)

    {:noreply, socket}
  end

  def handle_info({:game_over, scores}, socket) do
    socket =
      socket
      |> assign(:state, :game_over)
      |> assign(:scores, scores)

    {:noreply, socket}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp init_socket(socket, id) do
    socket
    |> assign(:server, id)
    |> assign(:players, [])
    |> assign(:state, :welcome)
    |> assign(:show_solution, false)
    |> assign(:scores, nil)
    |> assign(:question, nil)
    |> assign(:message, nil)
    |> assign(:time, nil)
  end
end
