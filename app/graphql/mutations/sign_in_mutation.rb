module Mutations
  class SignInMutation < Mutations::BaseMutation
    null true

    argument :credentials, Types::AuthProviderCredentialsInput, required: false

    field :token, String, null: true
    field :user, Types::UserType, null: true

    def resolve(credentials: nil)
      # basic validation
      return unless credentials

      user = User.find_by email: credentials[:email]

      # ensures we have the correct user
      if user.nil?
        raise GraphQL::ExecutionError,
                "User not found."
      end
      return { status: 'sign in failed with incorrect credentials!' } unless user.authenticate(credentials[:password])

      # use Ruby on Rails - ActiveSupport::MessageEncryptor, to build a token
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.credentials.secret_key_base.byteslice(0..31))
      token = crypt.encrypt_and_sign("user-id:#{ user.id }")
      context[:session][:token] = token
      RecipeSchema.subscriptions.trigger("userSignedIn", {}, current_user)
      { token: token, user: current_user }
    end
  end
end