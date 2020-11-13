module Mutations
  class UpdateRecipeMutation < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :attributes, Types::RecipeAttributes, required: true

    field :myrecipe, Types::MyrecipeType, null: true
    field :errors, Types::ValidationErrorsType, null: true

    def resolve(attributes:)
      check_authentication!
      myrecipe = Myrecipe.find_by(id: id)
      if myrecipe.nil?
        raise GraphQL::ExecutionError,
                "Recipe not found."
      end

      if current_user != myrecipe.user
        raise GraphQL::ExecutionError,
              "You are not allowed to edit this recipe."
      end

      if myrecipe.update(attributes.to_h)
        RecipeSchema.subscriptions.trigger("recipeUpdated", {}, myrecipe)
        { myrecipe: myrecipe }
      else
        { errors: myrecipe.errors }
      end
    end
  end
end