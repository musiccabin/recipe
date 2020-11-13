module Mutations
    class CreateUser < BaseMutation
      # often we will need input types for specific mutation
      # in those cases we can define those input types in the mutation class itself
      class AuthProviderSignupData < Types::BaseInputObject
        argument :credentials, Types::AuthProviderCredentialsInput, required: false
      end
  
      argument :attributes, Types::UserAttributes, required: true
      argument :auth_provider, AuthProviderSignupData, required: false
  
      type Types::UserType
  
      def resolve(attributes: nil, auth_provider: nil)
        user = User.create!(attributes.to_h.merge(
            is_admin: false,
            email: auth_provider&.[](:credentials)&.[](:email),
            password: auth_provider&.[](:credentials)&.[](:password)
            ))
        RecipeSchema.subscriptions.trigger("userCreated", {}, user)
      end
    end
  end