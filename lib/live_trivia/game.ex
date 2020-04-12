defmodule LiveTrivia.Game do
  use GenServer

  alias LiveTrivia.Trivia
  alias LiveTrivia.Game.State

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  def register_user(id, name) do
    GenServer.call(via_tuple(id), {:register_user, name})
  end

  def start_game(id) do
    GenServer.cast(via_tuple(id), :start_game)
  end

  def answer_question(id, name, answer) do
    GenServer.cast(via_tuple(id), {:answer, name, answer})
  end

  @impl true
  def init(id) do
    {:ok, State.init(id)}
  end

  @impl true
  def handle_call({:register_user, name}, {pid, _}, state) do
    current_players =
      LiveTriviaWeb.Presence.list("players:" <> state.id)
      |> Map.keys()

    state_players = Map.keys(state.players)

    cond do
      state.started && not (name in state_players) ->
        {:reply, {:error, :already_started}, state}

      name in state_players and name in current_players ->
        {:reply, {:error, :already_registered}, state}

      true ->
        state_prime =
          if not (name in state_players) do
            Map.update!(state, :players, &Map.put(&1, name, 0))
          else
            state
          end

        LiveTriviaWeb.Presence.track(pid, "players:" <> state.id, name, %{})

        broadcast_game(state.id, :update_players)

        {:reply, :ok, state_prime}
    end
  end

  @impl true
  def handle_cast(:start_game, state) do
    broadcast_game(state.id, {:loading, "Starting game!"})

    flush_messages()

    state_prime = load_questions(state)

    send(self(), :display_question)
    {:noreply, state_prime}
  end

  @impl true
  def handle_cast({:answer, name, answer}, state) do
    num_answer = Enum.count(state.answers) + 1

    answers = Map.put(state.answers, name, %{answer: answer, position: num_answer})

    broadcast_game(state.id, {:locked_in, Map.keys(answers)})

    if num_answer == Enum.count(state.players) do
      :timer.cancel(state.timer)
      send(self(), :display_answer)
    end

    {:noreply, Map.put(state, :answers, answers)}
  end

  @impl true
  def handle_info(:load_round, state) do
    round = hd(state.rounds)

    msg =
      case round do
        :easy -> "A WALK IN THE PARK"
        :medium -> "MEDIUM MAYHEM: DOUBLE POINTS"
        :hard -> "DASTARDLY DIFFICULT: 3 TIMES THE POINTS"
        :true_false -> "BONUS ROUND: TRUE OR FALSE"
        :finale -> "FINALE: THE END IS NEAR!"
      end

    broadcast_game(state.id, {:loading, msg})

    state_prime =
      load_questions(state)
      |> Map.put(:current_round, round)

    send(self(), :display_question)
    {:noreply, state_prime}
  end

  @impl true
  def handle_info(:display_question, state) do
    cond do
      state.questions == [] and state.rounds == [] ->
        send(self(), :game_over)
        {:noreply, state}

      state.questions == [] ->
        send(self(), :load_round)
        {:noreply, state}

      true ->
        [question | questions] = state.questions

        time = 30

        broadcast_game(state.id, {:display_question, question, time})

        {:ok, timer} = :timer.send_interval(1_000, :tick)

        state_prime =
          state
          |> Map.put(:timer, timer)
          |> Map.put(:time, time)
          |> Map.put(:questions, questions)
          |> Map.put(:question, question)

        {:noreply, state_prime}
    end
  end

  @impl true
  def handle_info(:tick, state) do
    time = state.time - 1

    broadcast_game(state.id, {:tick, time})

    if time == 0 do
      :timer.cancel(state.timer)

      broadcast_game(state.id, :out_of_time)

      send(self(), :display_answer)
    end

    {:noreply, Map.put(state, :time, time)}
  end

  @impl true
  def handle_info(:display_answer, state) do
    :timer.sleep(1_000)
    flush_messages()

    broadcast_game(state.id, :display_answer)

    :timer.sleep(5_000)

    answer = state.question[:solution]
    scores = calculate_scores(state, answer)
    ranked_scores = rank_scores(scores)

    broadcast_game(state.id, {:display_scores, ranked_scores})

    :timer.sleep(5_000)

    state_prime =
      state
      |> Map.put(:players, scores)
      |> Map.put(:answers, %{})

    send(self(), :display_question)
    {:noreply, state_prime}
  end

  def handle_info(:game_over, state) do
    ranked_scores = rank_scores(state.players)

    broadcast_game(state.id, {:game_over, ranked_scores})

    state_prime = State.reset(state)

    {:noreply, state_prime}
  end

  defp broadcast_game(id, msg) do
    Phoenix.PubSub.broadcast!(
      LiveTrivia.PubSub,
      "games:" <> id,
      msg
    )
  end

  defp load_questions(state) do
    [round | rounds] = state.rounds

    questions = Trivia.get(round)

    :timer.sleep(5_000)
    flush_messages()

    state
    |> Map.put(:questions, questions)
    |> Map.put(:rounds, rounds)
    |> Map.put(:current_round, round)
    |> Map.put(:started, true)
  end

  defp calculate_scores(state, answer) do
    for {name, score} <- state.players, into: %{} do
      player_answer = state.answers[name]

      if player_answer[:answer] == answer do
        multiplier =
          case state.current_round do
            :finale -> min(abs(min(player_answer.position, 3) - 4), 3)
            :hard -> 3
            :medium -> 2
            _ -> 1
          end

        {name, score + 100 * multiplier}
      else
        {name, score}
      end
    end
  end

  defp rank_scores(scores) do
    iter =
      Stream.iterate(1, &(&1 + 1))
      |> Stream.map(&String.to_atom("#{&1}"))

    scores
    |> Enum.sort_by(fn {_, score} -> score end, &>=/2)
    |> Enum.zip(iter)
    |> Enum.map(fn {{name, score}, place} -> {place, %{name: name, score: score}} end)
  end

  defp via_tuple(id) do
    LiveTrivia.Registry.via_tuple({__MODULE__, id})
  end

  defp flush_messages(timeout \\ 100) do
    receive do
      _ ->
        flush_messages()
    after
      timeout -> :ok
    end
  end
end
