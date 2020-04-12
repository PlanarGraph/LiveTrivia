defmodule LiveTrivia.Trivia do
  @base "https://opentdb.com/api.php?"

  def get(:easy), do: get_trivia(10, type: "multiple", difficulty: "easy")
  def get(:medium), do: get_trivia(10, type: "multiple", difficulty: "medium")
  def get(:hard), do: get_trivia(10, type: "multiple", difficulty: "hard")
  def get(:true_false), do: get_trivia(10, type: "boolean")
  def get(:finale), do: get_trivia(10, difficulty: "hard")

  def get_trivia(number, opts \\ []) do
    number
    |> build_url(opts)
    |> String.to_charlist()
    |> :httpc.request()
    |> parse_response()
    |> Enum.filter(fn qo -> qo["category"] != "Entertainment: Japanese Anime & Manga" end)
    |> Enum.filter(fn qo -> qo["category"] != "Entertainment: Video Games" end)
    |> Enum.map(&build_question/1)
  end

  defp build_question(qo) do
    correct =
      qo["correct_answer"]
      |> HtmlEntities.decode()

    incorrect =
      qo["incorrect_answers"]
      |> Enum.map(&HtmlEntities.decode/1)

    answers =
      [correct | incorrect]
      |> shuffle()
      |> (&Enum.zip(["A", "B", "C", "D"], &1)).()
      |> Enum.into(%{})

    question =
      qo["question"]
      |> HtmlEntities.decode()

    solution =
      answers
      |> Enum.filter(fn {_, v} -> v == correct end)
      |> Enum.map(fn {k, _} -> k end)
      |> hd()

    %{
      question: question,
      answers: answers,
      solution: solution
    }
  end

  defp parse_response(response) do
    {:ok, {_, _, body}} = response

    body
    |> Jason.decode!()
    |> Map.get("results", [])
  end

  defp build_url(number, opts) do
    amount = "amount=#{number}"
    type = build_helper(opts[:type], "type=")
    difficulty = build_helper(opts[:difficulty], "difficulty=")

    params = Enum.join([amount, type, difficulty], "&")

    @base <> params
  end

  defp shuffle(list) do
    for {_, v} <- Enum.sort(for x <- list, do: {:rand.uniform(), x}), do: v
  end

  defp build_helper(nil, _), do: ""
  defp build_helper(val, str), do: str <> val
end
