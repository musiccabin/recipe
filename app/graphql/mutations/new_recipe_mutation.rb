module Mutations
  class NewRecipeMutation < Mutations::BaseMutation
    argument :attributes, Types::RecipeAttributes, required: true
    argument :ingredients, [Types::IngredientAttributes], required: true

    field :recipe, Types::MyrecipeType, null: true
    field :errors, Types::ValidationErrorsType, null: true

    def resolve(attributes:, ingredients:)
      check_authentication!

      # if current_user.is_admin? == false
      #   raise GraphQL::ExecutionError,
      #         "You are not allowed to add new recipes."
      # end

      recipe = Myrecipe.new(attributes.to_h.merge(user: current_user))

      if recipe.save
        add_ingredients_to_recipe(recipe, ingredients)
        RecipeSchema.subscriptions.trigger("recipeAdded", {}, recipe)
        { recipe: recipe }
      else
        { errors: recipe.errors }
      end
    end
  end
end