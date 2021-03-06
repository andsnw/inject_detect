defmodule InjectDetect.Event.RequestedSignInToken do
  defstruct email: nil,
            requested_token: nil,
            user_id: nil
end

defimpl InjectDetect.State.Reducer,
   for: InjectDetect.Event.RequestedSignInToken do

  def apply(event, state) do
    put_in(state, [Lens.key(:users),
                   Lens.filter(&(&1.id == event.user_id)),
                   Lens.key(:requested_token)], event.requested_token)
  end

end
