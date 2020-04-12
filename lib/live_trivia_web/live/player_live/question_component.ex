defmodule LiveTriviaWeb.PlayerLive.QuestionComponent do
  use Phoenix.LiveComponent

  import Phoenix.HTML.Form

  def render(assigns) do
    ~L"""
    <section class="player-question">
      <div class="p-question"><b><%= @question.question %></b></div>
      <div class="p-answer">
        <%= f = form_for :answer, "#", [phx_submit: :submit] %>
          <%= for {letter, answer} <- @question.answers do %>
            <%= radio_button f, :answer, letter %>
            <%= label for: "answer_answer_#{letter}" do %>
              <%= letter <> ": " <> answer %>
            <% end %>
          <% end %>
          <%= if @answerable do %>
            <%= submit "Lock In" %>
          <% end %>
        </form>
      </div>
    </section>
    """
  end
end
