defmodule LiveTriviaWeb.PlayerLive.ScoreComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <%= case @place do %>
      <% :"1" -> %> <section class="player-first">
      <% :"2" -> %> <section class="player-second">
      <% _ -> %> <section class="player-third">
    <% end %>
      <div class="p-name"><%= @name %></div>
      <div class="p-score">Your score: <%= @score.score %></div>
      <%= cond do %>
        <%= @place == :"1" && @game_over -> %>
          <div class="p-place"><b>You Win!</b></div>
        <%= @place == :"1" -> %>
          <div class="p-place"><b>You are in first place!</b></div>
        <% true -> %>
          <div></div>
      <% end %>
    </section>

    <%= if @game_over do %>
      <button phx-click="restart">Play Again</button>
    <% end %>
    """
  end
end
