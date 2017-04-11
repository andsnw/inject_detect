defmodule InjectDetect.Event.IngestedUnexpectedQuery do
  defstruct application_id: nil,
            collection: nil,
            queried_at: nil,
            query: nil,
            type: nil

  def convert_from(event, _), do: struct(__MODULE__, event)

  def stream(event), do: "application_id: #{event.application_id}"

end

defimpl InjectDetect.State.Reducer,
   for: InjectDetect.Event.IngestedUnexpectedQuery do

  alias InjectDetect.State.Query

  def apply(event, state) do
    query = %{
      collection: event.collection,
      queried_at: event.queried_at,
      query: event.query,
      type: event.type
    }
    key = Query.to_key(query)
    unexpected_queries_path = [:unexpected_queries, event.application_id, key]
    applications_path = [:applications, event.application_id, :unexpected_queries]
    state
    |> update_in(unexpected_queries_path, &add_to_unexpected(&1, query))
    |> update_in(applications_path, &add_to_application(&1, key))
  end

  def add_to_unexpected(nil, query), do: %{query | count: 1}

  def add_to_application(unexpected_queries, key) do
    Enum.uniq([key | unexpected_queries])
  end

end