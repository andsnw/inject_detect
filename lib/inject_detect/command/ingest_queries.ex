defmodule InjectDetect.Command.IngestQueries do
  defstruct application_id: nil,
            queries: nil
end

defimpl InjectDetect.Command, for: InjectDetect.Command.IngestQueries do

  alias InjectDetect.Event.AddedExpectedQuery
  alias InjectDetect.Event.AddedUnexpectedQuery
  alias InjectDetect.Event.IngestedQuery
  alias InjectDetect.Event.IngestedExpectedQuery
  alias InjectDetect.Event.IngestedUnexpectedQuery
  alias InjectDetect.State
  alias InjectDetect.State.Application
  alias InjectDetect.State.ExpectedQuery
  alias InjectDetect.State.UnexpectedQuery

  import InjectDetect, only: [generate_id: 0]

  def find_query(query, added, find) do
    find.(query) || Enum.find(added, fn
      added -> query.collection == added.collection &&
               query.query == added.query &&
               query.type == added.type
    end)
  end

  def find_expected_query(query, added) do
    find_query(query, added, &ExpectedQuery.find/1)
  end

  def find_unexpected_query(query, added) do
    find_query(query, added, &UnexpectedQuery.find/1)
  end

  def ingest_query(%{training_mode: true}, query, {added, events}) do
    case find_expected_query(query, added) do
      nil       -> query = Map.put_new(query, :id, generate_id)
                   {[query | added],
                    events ++ [struct(IngestedQuery, query),
                               struct(AddedExpectedQuery, query),
                               struct(IngestedExpectedQuery, query)]}
      %{id: id} -> query = Map.put_new(query, :id, id)
                   {added,
                    events ++ [struct(IngestedQuery, query),
                               struct(IngestedExpectedQuery, query)]}
    end
  end

  def ingest_query(%{training_mode: false}, query, {added, events}) do
    case {find_expected_query(query, added),
          find_unexpected_query(query, added)} do
      {nil, nil}       -> query = Map.put_new(query, :id, generate_id)
                          {[query | added],
                           events ++ [struct(IngestedQuery, query),
                                      struct(AddedUnexpectedQuery, query),
                                      struct(IngestedUnexpectedQuery, query)]}
      {nil, %{id: id}} -> query = Map.put_new(query, :id, id)
                          {added,
                           events ++ [struct(IngestedQuery, query),
                                      struct(IngestedUnexpectedQuery, query)]}
      {%{id: id}, _}   -> query = Map.put_new(query, :id, id)
                          {added,
                           events ++ [struct(IngestedQuery, query),
                                      struct(IngestedExpectedQuery, query)]}
    end
  end

  def ingest_for_application(nil, _command) do
    {:error, %{code: :invalid_token,
               error: "Invalid application token",
               message: "Invalid token"}}
  end

  def ingest_for_application(application, command) do
    events = command.queries
    |> Enum.map(&(Map.put_new(&1, :application_id, application.id)))
    |> Enum.reduce({[], []}, &ingest_query(application, &1, &2))
    |> elem(1)
    |> List.flatten
    {:ok, events}
  end

  def handle(command, _context) do
    Application.find(command.application_id)
    |> ingest_for_application(command)
  end

end
