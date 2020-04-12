defmodule LiveTriviaWeb.DisplayLive.LoadingComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <section class="loading">
      <div>Next Round:</div>
      <div><%= @message %></div>
    </section>
    """
  end
end
