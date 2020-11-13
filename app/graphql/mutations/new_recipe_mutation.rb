module Mutations
  class NewRecipeMutation < Mutations::BaseMutation
    argument :attributes, Types::RecipeAttributes, required: true

    field :myrecipe, Types::MyRecipeType, null: true
    field :errors, Types::ValidationErrorsType, null: true

    def resolve(attributes:)
      check_authentication!

      if current_user.is_admin? == false
        raise GraphQL::ExecutionError,
              "You are not allowed to add new recipes."
      end

      myrecipe = Myrecipe.new(attributes.to_h.merge(user: current_user))

      if myrecipe.save
        RecipeSchema.subscriptions.trigger("recipeAdded", {}, myrecipe)
        { myrecipe: myrecipe }
      else
        { errors: myrecipe.errors }
      end
    end
  end
end