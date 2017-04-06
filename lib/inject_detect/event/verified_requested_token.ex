defmodule InjectDetect.Event.VerifiedRequestedToken do
  defstruct token: nil,
            user_id: nil

  def convert_from(event, _), do: struct(__MODULE__, event)

end

defimpl InjectDetect.State.Reducer,
   for: InjectDetect.Event.VerifiedRequestedToken do

  import InjectDetect.State, only: [with_attrs: 1]

  def apply(%{user_id: user_id}, state) do
    put_in(state, [:users,
                   with_attrs(id: user_id),
                   :requested_token], nil)
  end

end