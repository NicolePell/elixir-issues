defmodule Issues.GithubIssues do
  @user_agent [ {"User-agent", "Elixir nic@kittykat.com"} ]

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  def handle_response({ :ok, %{status_code: 200, body: body}}) do
    { :ok, Poison.Parser.parse!(body) }
  end

  def handle_response({ _, %{status_code: _, body: body}}) do
    { :error, Poison.Parser.parse!(body) }
  end

  def process({ user, project, _count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
  end

  def decode_response({:ok, body}), do: body

  def decode_response(:error, error) do
    {_, message} = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end

end