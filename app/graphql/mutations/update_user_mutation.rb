module Mutations
    class UpdateUserMutation < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :attributes, Types::UserAttributes, required: true
  
      field :user, Types::UserType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(attributes:)
        check_authentication!
        
        user = User.find_by(id: id)
        if user.nil?
          raise GraphQL::ExecutionError,
                  "User not found."
        end
  
        if current_user != user
          raise GraphQL::ExecutionError,
                "You are not allowed to edit another user's information."
        end
  
        if user.update(attributes.to_h)
          RecipeSchema.subscriptions.trigger("userUpdated", {}, user)
          { user: user }
        else
          { errors: user.errors }
        end
      end
    end
  end