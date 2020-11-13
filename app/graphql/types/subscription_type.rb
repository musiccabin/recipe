module Types
    class SubscriptionType < GraphQL::Schema::Object
      field :recipe_added, Types::MyrecipeType, null: false, description: "A new recipe was added"
      field :recipe_updated, Types::MyrcipeType, null: false, description: "Existing recipe was updated"
      field :leftover_added, Types::LeftoverType, null: false, description: "A new leftover was added"
      field :leftover_updated, Types::LeftoverType, null: false, description: "Leftover was updated"
      field :recipe_added_to_mealplan, Types::MyrecipemealplanlinkType, null: false, description: "Recipe is added to mealplan"
      field :recipe_removed_from_mealplan, Types::MealplanType, null: false, description: "Recipe is removed from mealplan"
      field :cleared_all_from_mealplan, Types::MealplanType, null: false, description: "All recipes removed from mealplan"
      field :grocery_added, Types::GroceryType, null: false, description: "New grocery item was added"
      field :grocery_updated, Types::GroceryType, null: false, description: "Existing grocery item was updated"
      field :grocery_removed, Types::UserType, null: false, description: "Existing grocery item was removed"
      field :leftover_usage_added, Types::LeftoverUsageType, null: false, description: "A new leftover usage was added"
      field :leftover_usage_removed, Types::UserType, null: false, description: "Existing leftover usage was removed"
      field :favourite_added, Types::FavouriteType, null: false, description: "A new favourite was added"
      field :favourite_removed, Types::UserType, null: false, description: "Existing favourite was removed"
      field :completion_added, Types::CompletionType, null: false, description: "A new completion was added"
      field :completion_removed, Types::UserType, null: false, description: "Existing completion was removed"
      field :recipe_is_hidden, Types::MyrecipeType, null: false, description: "Existing recipe was hidden"
      field :recipe_is_published, Types::MyrecipeType, null: false, description: "Existing recipe was published"
      field :leftover_removed, Types::UserType, null: false, description: "Existing leftover was removed"
      field :user_updated, Types::UserType, null: false, description: "Existing user was updated"
      field :user_created, Types::UserType, null: false, description: "New user was created"
      field :user_signed_in, Types::UserType, null: false, description: "Existing user was signed in"


      def recipe_added; end
      def recipe_updated; end
      def leftover_added; end
      def leftover_updated; end
      def recipe_added_to_mealplan; end
      def recipe_removed_from_mealplan; end
      def cleared_all_from_mealplan; end
      def grocery_added; end
      def grocery_updated; end
      def grocery_removed; end
      def leftover_usage_added; end
      def leftover_usage_removed; end
      def favourite_added; end
      def favourite_removed; end
      def completion_added; end
      def completion_removed; end
      def recipe_is_hidden; end
      def recipe_is_published; end
      def leftover_removed; end
      def user_updated; end
      def user_created; end
      def user_signed_in; end
    end
  end