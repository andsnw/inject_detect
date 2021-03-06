defmodule InjectDetect.Event.GivenAuthToken do
  defstruct auth_token: nil,
            user_id: nil
end

defimpl InjectDetect.State.Reducer,
   for: InjectDetect.Event.GivenAuthToken do

  def apply(event, state) do
    put_in(state, [Lens.key(:users),
                   Lens.filter(&(&1.id == event.user_id)),
                   Lens.key(:auth_token)], event.auth_token)
  end

end
