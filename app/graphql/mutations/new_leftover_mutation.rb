module Mutations
    class NewLeftoverMutation < Mutations::BaseMutation
      argument :attributes, Types::IngredientAttributes, required: true
  
      field :leftover, Types::LeftoverType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(attributes:)
        check_authentication!
  
        leftover = Leftover.new(attributes.to_h.merge(user: current_user))
  
        if leftover.save
          RecipeSchema.subscriptions.trigger("leftoverAdded", {}, leftover)
          { leftover: leftover }
        else
          { errors: leftover.errors }
        end
      end
    end
end