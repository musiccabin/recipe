module Mutations
    class NewFavMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true
  
      def resolve(attributes:)
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