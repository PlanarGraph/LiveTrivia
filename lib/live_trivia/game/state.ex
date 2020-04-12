defmodule LiveTrivia.Game.State do
  defstruct [
    :id,
    :rounds,
    :question,
    :current_round,
    :questions,
    :state,
    :players,
    :answers,
    :started,
    :time,
    :timer
  ]

  def init(id) do
    %LiveTrivia.Game.State{
      id: id,
      rounds: init_rounds(),
      question: nil,
      current_round: nil,
      questions: [],
      answers: %{},
      players: %{},
      started: false,
      time: 40,
      timer: nil
    }
  end

  def reset(state) do
    state
    |> Map.put(:rounds, init_rounds())
    |> Map.update!(:players, fn players ->
      players
      |> Enum.map(fn {name, _} -> {name, 0} end)
      |> Enum.into(%{})
    end)
  end

  # [:easy, {:true_false, 4}, :meduim, :hard]
  def init_rounds() do
    [:easy, {:true_false, 4}, :medium, :hard, :finale]
    |> Stream.map(fn
      {round, divisor} ->
        rnd = :random.uniform(100)

        if rem(rnd, divisor) == 0 do
          round
        else
          nil
        end

      round ->
        round
    end)
    |> Enum.filter(& &1)
  end
end
