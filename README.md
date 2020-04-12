# LiveTrivia

To start the Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Visit [`localhost:4000/display/{id}`](http://localhost:4000/display) to display the game, where `{id}` is an arbitrary room id chosen by the host.

Players can then join the game by visiting the displayed link (usually of the form `{ip-addr}:4000/play`) on their computers or mobile devices, which will then prompt them to enter their name and the room id.
