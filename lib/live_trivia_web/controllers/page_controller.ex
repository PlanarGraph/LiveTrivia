defmodule LiveTriviaWeb.PageController do
  use LiveTriviaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
