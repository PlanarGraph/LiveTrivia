defmodule LiveTriviaWeb.PlayerLive do
  use Phoenix.LiveView

  alias LiveTrivia.Game

  def render(assigns) do
    ~L"""
    <p class="alert alert-info"><%= live_flash(@flash, :info) %></p>
    <p class="alert alert-danger"><%= live_flash(@flash, :error) %></p>
    <%= case @state do %>
      <% :login -> %>
        <%= live_component @socket, LiveTriviaWeb.PlayerLive.LoginComponent %>

      <% :waiting -> %>
        <%= live_component @socket, LiveTriviaWeb.PlayerLive.WaitingComponent, name: @name %>

      <% :display_question -> %>
        <%= live_component @socket, LiveTriviaWeb.PlayerLive.QuestionComponent, question: @question, answerable: @answerable %>

      <% :display_choice -> %>
        <%= live_component @socket, LiveTriviaWeb.PlayerLive.ChoiceComponent, question: @question, answer: @answer, show_solution: @show_solution %>

      <% :display_score -> %>
        <%= live_component @socket, LiveTriviaWeb.PlayerLive.ScoreComponent, name: @name, score: @score, place: @place, game_over: false %>

      <% :game_over -> %>
        <%= live_component @socket, LiveTriviaWeb.PlayerLive.ScoreComponent, name: @name, score: @score, place: @place, game_over: true %>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :state, :login)}
  end

  def handle_event("register", %{"login" => %{"name" => name, "server" => id}}, socket) do
    case LiveTrivia.Game.register_user(id, name) do
      {:error, :already_started} ->
        socket = put_flash(socket, :error, "Game has already started")
        {:noreply, socket}

      {:error, :already_registered} ->
        socket = put_flash(socket, :error, "That name has been taken")
        {:noreply, socket}

      :ok ->
        LiveTriviaWeb.Endpoint.subscribe("games:" <> id)

        socket = clear_flash(socket)

        {:noreply, init_socket(socket, id, name)}
    end
  end

  def handle_event("restart", _, socket) do
    id = socket.assigns.server
    name = socket.assigns.name
    LiveTrivia.Game.start_game(id)
    {:noreply, init_socket(socket, id, name)}
  end

  def handle_event("submit", %{"answer" => %{"answer" => answer}}, socket) do
    Game.answer_question(
      socket.assigns.server,
      socket.assigns.name,
      answer
    )

    socket =
      socket
      |> assign(:answer, answer)
      |> assign(:state, :display_choice)
      |> assign(:show_solution, false)

    {:noreply, socket}
  end

  ## Submit with no answers are ignored
  def handle_event("submit", _, socket) do
    {:noreply, socket}
  end

  def handle_info({:loading, _}, socket) do
    socket =
      socket
      |> assign(:state, :waiting)

    {:noreply, socket}
  end

  def handle_info({:display_question, question, _}, socket) do
    socket =
      socket
      |> assign(:state, :display_question)
      |> assign(:question, question)
      |> assign(:answerable, true)

    {:noreply, socket}
  end

  def handle_info(:out_of_time, socket) do
    {:noreply, assign(socket, :answerable, false)}
  end

  def handle_info(:display_answer, socket) do
    {:noreply, assign(socket, :show_solution, true)}
  end

  def handle_info({:display_scores, scores}, socket) do
    {place, score} = Enum.find(scores, fn {_, v} -> v[:name] == socket.assigns.name end)

    socket =
      socket
      |> assign(:state, :display_score)
      |> assign(:score, score)
      |> assign(:place, place)

    {:noreply, socket}
  end

  def handle_info({:game_over, scores}, socket) do
    {place, score} = Enum.find(scores, fn {_, v} -> v.name == socket.assigns.name end)

    socket =
      socket
      |> assign(:state, :game_over)
      |> assign(:score, score)
      |> assign(:place, place)

    {:noreply, socket}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp init_socket(socket, id, name) do
    socket
    |> assign(:server, id)
    |> assign(:name, name)
    |> assign(:state, :waiting)
    |> assign(:question, nil)
    |> assign(:answerable, nil)
    |> assign(:show_solution, nil)
    |> assign(:score, nil)
    |> assign(:answer, nil)
    |> assign(:place, nil)
  end
end
