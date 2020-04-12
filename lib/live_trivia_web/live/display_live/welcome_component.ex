defmodule LiveTriviaWeb.DisplayLive.WelcomeComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <section class="welcome-title">
      <h1>Welcome to LiveTrivia!</h1>
      <h2>Go to <b><%= format_address() %></b> and join <%= @server %>!</h2>
    </section>
    <section class="welcome-join">
      <h2>Players:<h2>
        <%= for player <- @players do %>
          <div><%= player %></div>
        <% end %>
    </section>
    <div class ="welcome-button">
      <button phx-click="start">Start</button>
    </div>
    """
  end

  defp format_address() do
    get_ip() <> ":4000/play/"
  end

  defp get_ip() do
    {:ok, [{sections, _, _} | _]} = :inet.getif()

    sections
    |> Tuple.to_list()
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join(".")
  end
end
