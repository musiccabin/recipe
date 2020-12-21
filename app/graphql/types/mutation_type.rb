module Types
  class MutationType < Types::BaseObject
    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World"
    end

    field :sign_in, mutation: Mutations::SignInMutation
    field :new_recipe, mutation: Mutations::NewRecipeMutation
    field :update_recipe, mutation: Mutations::UpdateRecipeMutation
    field :new_leftover, mutation: Mutations::NewLeftoverMutation
    field :update_leftover, mutation: Mutations::UpdateLeftoverMutation
    field :add_to_mealplan, mutation: Mutations::AddToMealplanMutation
    field :remove_from_mealplan, mutation: Mutations::RemoveFromMealplanMutation
    field :clear_all_from_mealplan, mutation: Mutations::ClearAllFromMealplanMutation
    field :new_grocery, mutation: Mutations::NewGroceryMutation
    field :update_grocery, mutation: Mutations::UpdateGroceryMutation
    field :remove_grocery, mutation: Mutations::RemoveGroceryMutation
    field :update_usages, mutation: Mutations::UpdateUsagesMutation
    field :used_recipe_amounts, mutation: Mutations::UsedRecipeAmountsMutation
    field :remove_usages, mutation: Mutations::RemoveUsagesMutation
    field :new_fav, mutation: Mutations::NewFavMutation
    field :remove_fav, mutation: Mutations::RemoveFavMutation
    field :new_completion, mutation: Mutations::NewCompletionMutation
    field :remove_completion, mutation: Mutations::RemoveCompletionMutation
    field :hide_recipe, mutation: Mutations::HideRecipeMutation
    field :publish_recipe, mutation: Mutations::PublishRecipeMutation
    field :remove_leftover, mutation: Mutations::RemoveLeftoverMutation
    field :update_user, mutation: Mutations::UpdateUserMutation
    field :create_user, mutation: Mutations::CreateUserMutation
  end
end
