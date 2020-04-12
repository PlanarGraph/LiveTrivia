defmodule LiveTriviaWeb.DisplayLive.ScoreComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <%= if not(@game_over) do %>
      <h1 class="display-score-header">Leaderboard</h1>
    <% else %>
      <h1 class="display-score-header">Game Over!</h1>
      <h1 class="display-winner-header"><%= @scores[:"1"][:name] %> wins!</h1>
    <% end %>
    <section class="display-score">
      <%= for {place, %{name: name, score: score}} <- @scores do %>
        <div><%= Atom.to_string(place) <> ". #{name}: #{score}" %></div>
      <% end %>
    </section>
    """
  end
end
