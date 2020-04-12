defmodule LiveTriviaWeb.Router do
  use LiveTriviaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {LiveTriviaWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveTriviaWeb do
    pipe_through :browser

    live "/play", PlayerLive
    live "/display/:id", DisplayLive
    # get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveTriviaWeb do
  #   pipe_through :api
  # end
end
