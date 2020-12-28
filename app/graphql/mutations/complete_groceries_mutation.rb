module Mutations
    class CompleteGroceriesMutation < Mutations::BaseMutation
      argument :groceries, [Types::IngredientAttributes], required: false
      argument :ids, [Integer], required: true
  
      field :status, String, null: true
      field :errors, [Types::ValidationErrorsType], null: false
  
      def resolve(ids:, groceries: nil)
        errors = []
        check_authentication!

        ids.each do |id|
            grocery = Grocery.find_by(id: id)
            check_grocery_exists!(grocery)
            grocery.is_completed = true
            errors << grocery.errors unless grocery.save
        end
        
        if errors.empty?
            { status: 'completed grocery items!', errors: errors } 
        else
            { errors: errors }
        end
      end
    end
end