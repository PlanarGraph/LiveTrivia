defmodule LiveTriviaWeb.PlayerLive.ChoiceComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <%= cond do %>
      <%= @show_solution && @answer == @question.solution -> %>
        <section class="player-correct">
      <%= @show_solution -> %>
        <section class="player-incorrect">
      <% true -> %>
        <section class="player-question">
    <% end %>
      <div class="p-question"><%= @question.question %></div>
      <div class="p-lockin">You locked-in:</div>
      <div class="p-lockin-answer">
        <b><%= @answer %>: <%= @question.answers[@answer] %></b>
      </div>
    </section>
    """
  end
end
