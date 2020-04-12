defmodule LiveTriviaWeb.PlayerLive.WaitingComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <section class="p-waiting-background">
      <div>
        Waiting for next question.
      </div>
    </section>
    """
  end
end
