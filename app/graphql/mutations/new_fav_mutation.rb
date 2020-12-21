module Mutations
    class NewFavMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true

      field :favourite, Types::FavouriteType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(recipe_id:)
        check_authentication!
  
        recipe = Myrecipe.find_by(id: recipe_id)
        check_recipe_exists!(recipe)
  
        fav = Favourite.new(myrecipe: recipe, user: current_user)
        if fav.save
          RecipeSchema.subscriptions.trigger("favouriteAdded", {}, fav)
          { favourite: fav }
        else
          { errors: fav.errors }
        end
      end
    end
end