defmodule LiveTriviaWeb.DisplayLive.MultipleComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <section class="multiple">
      <section class="top">
        <section class="question">
          <div><%= @question.question %></div>
        </section>
        <section class="time">
          <div><%= @time %></div>
        </section>
      </section>

      <section class="answers-box">
        <%= for {letter, answer} <- @question.answers do %>
          <%= if @show_solution and letter == @question.solution do %>
            <div class="solution"><%= "#{letter}: #{answer}" %></div>
          <% else %>
            <div class="answer"><%= "#{letter}: #{answer}" %></div>
          <% end %>
        <% end %>
      </section>

      <section class="locked-in">
        <div>Locked in:</div>
        <%= for player <- @locked_in do %>
          <div><%= player %></div>
        <% end %>
      </section>
    </section>
    """
  end
end
