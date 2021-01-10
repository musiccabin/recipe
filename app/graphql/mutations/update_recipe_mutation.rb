module Mutations
  class UpdateRecipeMutation < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :attributes, Types::RecipeAttributes, required: true
    argument :ingredients, [Types::IngredientAttributes], required: false

    field :recipe, Types::MyrecipeType, null: true
    field :errors, Types::ValidationErrorsType, null: true

    def resolve(attributes:, id:, ingredients: nil)
      check_authentication!

      recipe = Myrecipe.find_by(id: id)
      check_recipe_exists!(recipe)
      authenticate_item_owner!(recipe)

      if recipe.update(attributes.to_h)
        add_ingredients_to_recipe(recipe, ingredients) if ingredients
        RecipeSchema.subscriptions.trigger("recipeUpdated", {}, recipe)
        { recipe: recipe }
      else
        { errors: recipe.errors }
      end
    end
  end
end