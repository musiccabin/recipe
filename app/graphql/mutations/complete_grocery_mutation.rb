module Mutations
    class CompleteGroceryMutation < Mutations::BaseMutation
      argument :id, ID, required: true
  
      field :status, String, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(id:, groceries: nil)
        check_authentication!

        grocery = Grocery.find_by(id: id)
        check_grocery_exists!(grocery)
        grocery.is_completed = true
        
        if grocery.save
            { status: 'completed grocery item!' } 
        else
            { errors: errors }
        end
      end
    end
end