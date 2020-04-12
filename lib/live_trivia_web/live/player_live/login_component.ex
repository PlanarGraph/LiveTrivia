defmodule LiveTriviaWeb.PlayerLive.LoginComponent do
  use Phoenix.LiveComponent

  import Phoenix.HTML.Form

  def render(assigns) do
    ~L"""
    <div class="player-login">
      <%= f = form_for :login, "#", [phx_submit: :register] %>
        Name: <%= text_input f, :name %>
        Server: <%= text_input f, :server %>
        <%= submit "Enter" %>
      </form>
    </div>
    """
  end
end
