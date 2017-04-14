defmodule InjectDetect.Schema do
  use Absinthe.Schema

  alias InjectDetect.Command.{
    GetStarted,
    RequestSignInToken,
    SignOut,
    TurnOffTrainingMode,
    VerifyRequestedToken,
  }
  alias InjectDetect.CommandHandler
  alias InjectDetect.State
  alias InjectDetect.State.User
  alias InjectDetect.State.Application

  import_types InjectDetect.Schema.Types

  def auth(resolver) do
    error = {:error, %{code: :not_authenticated,
                       error: "Not authenticated",
                       message: "Not authenticated"}}
    fn
      (_args, %{context: %{user_id: nil}})     -> error
      (args, info = %{context: %{user_id: _}}) -> resolver.(args, info)
      (_args, _info)                           -> error
    end
  end

  def resolve_user(_args, %{context: %{user_id: user_id}}) do
    {:ok, User.find(user_id)}
  end

  def resolve_users(_args, %{context: %{user_id: _user_id}}) do
    {:ok, state} = State.get()
    users = for {_id, user} <- state.users, do: user
    {:ok, users}
  end

  def resolve_application(%{id: id}, %{context: %{user_id: user_id}}) do
    case application = Application.find(id) do
      %{user_id: ^user_id} -> {:ok, application}
      _                    -> {:error, %{code: :not_found,
                                         error: "Not found",
                                         message: "Not found"}}
    end
  end

  query do
    field :users, list_of(:user) do
      resolve auth &resolve_users/2
    end

    field :user, :user do
      resolve &resolve_user/2
    end

    field :application, :application do
      arg :id, non_null(:string)
      resolve &resolve_application/2
    end
  end

  def handle(command, resolve) do
    fn
      (args, data) ->
        command = struct(command, Map.merge(args, data.context))
        IO.inspect(command)
        case CommandHandler.handle(command, data.context) do
          {:ok, context} -> {:ok, resolve.(context)}
          error          -> error
        end
    end
  end

  def user(%{user_id: user_id}) do
    User.find(user_id)
  end

  def application(%{application_id: application_id}) do
    Application.find(application_id)
  end

  mutation do
    field :get_started, type: :user do
      arg :email, non_null(:string)
      arg :application_name, non_null(:string)
      arg :application_size, non_null(:string)
      arg :agreed_to_tos, :boolean
      resolve handle(GetStarted, &user/1)
    end

    field :request_sign_in_token, type: :user do
      arg :email, non_null(:string)
      resolve handle(RequestSignInToken, &user/1)
    end

    field :verify_requested_token, type: :user do
      arg :token, non_null(:string)
      resolve handle(VerifyRequestedToken, &user/1)
    end

    field :sign_out, type: :user do
      resolve auth handle(SignOut, &user/1)
    end

    field :turn_off_training_mode, type: :application do
      arg :application_id, non_null(:string)
      resolve auth handle(TurnOffTrainingMode, &application/1)
    end

  end

end
