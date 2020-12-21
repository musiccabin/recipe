module Mutations
    class RemoveFavMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true

      field :status, String, null: false
  
      def resolve(recipe_id:)
        check_authentication!

        fav = current_user.favourites&.find_by(myrecipe: recipe_id)
        if fav.present?
            authenticate_item_owner!(fav)
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