module Mutations
    class NewFavMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true

      field :favourite, Types::FavouriteType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(recipe_id:)
        check_authentication!
  
        myrecipe = Myrecipe.find_by(id: recipe_id)
        if myrecipe.nil?
          raise GraphQL::ExecutionError,
                "Recipe not found."
        end
  
        fav = Favourite.new(myrecipe: myrecipe, user: current_user)
        if fav.save
          RecipeSchema.subscriptions.trigger("favouriteAdded", {}, fav)
          { favourite: fav }
        else
          { errors: fav.errors }
        end
      end
    end
end