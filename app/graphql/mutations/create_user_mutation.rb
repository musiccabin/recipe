module Mutations
    class CreateUserMutation < BaseMutation
      # often we will need input types for specific mutation
      # in those cases we can define those input types in the mutation class itself
      class AuthProviderSignupData < Types::BaseInputObject
        argument :credentials, Types::AuthProviderCredentialsInput, required: false
      end
  
      argument :attributes, Types::UserAttributes, required: true
      argument :auth_provider, AuthProviderSignupData, required: false

      field :user, Types::UserType, null: true
      field :errors, [Types::ValidationErrorsType], null: true
  
      def resolve(attributes: nil, auth_provider: nil)
        user = User.create!(attributes.to_h.merge({
            is_admin: false,
            email: auth_provider&.[](:credentials)&.[](:email),
            password: auth_provider&.[](:credentials)&.[](:password)
        }))
        if user.nil?
          { errors: user.errors }
        else
          mealplan = Mealplan.create(user: user)
          if mealplan.nil?
            raise GraphQL::ExecutionError,
              "Unable to create meal plan for new user."
          end
          RecipeSchema.subscriptions.trigger("userCreated", {}, user)
          { user: user }
        end
      end
    end
  end