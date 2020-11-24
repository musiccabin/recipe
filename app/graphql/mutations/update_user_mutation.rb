module Mutations
    class UpdateUserMutation < Mutations::BaseMutation
      argument :attributes, Types::UserAttributes, required: true
      argument :tags, [String], required: false
      argument :dietary_restrictions, [String], required: false
  
      field :user, Types::UserType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(attributes:, tags: nil, dietary_restrictions: nil)
        check_authentication!
        
        user = User.find_by(id: attributes.id)
        if user.nil?
          raise GraphQL::ExecutionError,
                  "User not found."
        end
  
        if current_user != user
          raise GraphQL::ExecutionError,
                "You are not allowed to edit another user's information."
        end
  
        tag_ids = []
        current_user.usertaggings.destroy_all
        if tags         
          tags.each do |t|
            tag = Tag.find_by(name: t)
            if tag
              tag_ids << tag.id
            else
              raise GraphQL::ExecutionError,
                  "Tag not found."
            end
          end
        end

        dietaryrestriction_ids = []
        current_user.userdietaryrestrictionlinks.destroy_all
        if dietary_restrictions          
          dietary_restrictions.each do |d|
            restriction = Dietaryrestriction.find_by(name: d)
            if restriction
              dietaryrestriction_ids << restriction.id
            else
              raise GraphQL::ExecutionError,
                  "Dietary restriction not found."
            end
          end
        end

        if user.update(attributes.to_h.merge({tag_ids: tag_ids, dietaryrestriction_ids: dietaryrestriction_ids}))
          RecipeSchema.subscriptions.trigger("userUpdated", {}, user)
          { user: user }
        else
          { errors: user.errors }
        end
      end
    end
  end