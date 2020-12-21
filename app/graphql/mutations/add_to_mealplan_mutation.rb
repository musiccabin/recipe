module Mutations
    class AddToMealplanMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true
  
      field :link, Types::MyrecipemealplanlinkType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(recipe_id:)
        check_authentication!
  
        link = Myrecipemealplanlink.new(myrecipe: Myrecipe.find_by(id: recipe_id), mealplan: current_user.mealplan)
  
        if link.save
          RecipeSchema.subscriptions.trigger("recipeAddedToMealplan", {}, link)
          add_groceries_from_mealplan
          { link: link }
        else
          { errors: link.errors }
        end
      end
    end
end