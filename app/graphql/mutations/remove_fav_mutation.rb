module Mutations
    class RemoveFavMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true

      field :status, String, null: true
  
      def resolve(recipe_id:)
        check_authentication!

        fav = current_user.favourites&.find_by(myrecipe: recipe_id)
        if fav.present?
            if current_user != fav.user 
                raise GraphQL::ExecutionError,
                    "You are not allowed to edit this favourite."
            end
            fav.destroy
            RecipeSchema.subscriptions.trigger("favouriteRemoved", {}, current_user)
            { status: 'this recipe is removed from favourites!'}
        else
            raise GraphQL::ExecutionError,
                "This recipe was not in your favourites."
        end
      end
    end
end