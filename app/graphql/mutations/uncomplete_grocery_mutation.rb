module Mutations
    class UncompleteGroceryMutation < Mutations::BaseMutation
      argument :id, ID, required: true
  
      field :status, String, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(id:)
        check_authentication!

        grocery = Grocery.find_by(id: id)
        check_grocery_exists!(grocery)
        grocery.is_completed = false
        
        if grocery.save
            { status: 'uncompleted grocery item!' } 
        else
            { errors: errors }
        end
      end
    end
end