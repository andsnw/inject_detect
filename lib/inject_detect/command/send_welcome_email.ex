defmodule InjectDetect.Command.SendWelcomeEmail do
  defstruct user_id: nil,
            email: nil,
            requested_token: nil
end

defimpl InjectDetect.Command,
   for: InjectDetect.Command.SendWelcomeEmail do

  alias InjectDetect.Event.SentWelcomeEmail
  alias InjectDetect.State.User

  def handle(command, _context, state) do
    User.find(state, command.user_id)
    |> Email.welcome_html_email
    |> InjectDetect.Mailer.deliver_later
    {:ok, [%SentWelcomeEmail{user_id: command.user_id, email: command.email}]}
  end

end
