defmodule InjectDetect.Event.AddedExpectedQuery do
  defstruct application_id: nil,
            id: nil,
            collection: nil,
            queried_at: nil,
            query: nil,
            type: nil

  def convert_from(event, _), do: struct(__MODULE__, event)

end

defimpl InjectDetect.State.Reducer,
   for: InjectDetect.Event.AddedExpectedQuery do

  import InjectDetect.State.Application, only: [add_expected_query: 3]

  def apply(event, state) do
    add_expected_query(state, event.application_id, Map.from_struct(event))
  end

end
