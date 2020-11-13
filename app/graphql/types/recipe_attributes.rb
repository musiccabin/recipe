module Types
    class RecipeAttributes < Types::BaseInputObject
      description "Attributes for creating or updating a recipe"

      argument :title, String, required: true
      argument :videoURL, String, required: false
      argument :instructions, String, required: true
      argument :cooking_time, String, required: true
      argument :avatar_file_name, String, required: true
      argument :avatar_content_type, String, required: true
      argument :avatar_file_size, Integer, required: true
      argument :avatar_updated_at, GraphQL::Types::ISO8601DateTime, required: true
      argument :dietaryrestriction_ids, [Integer], required: false
      argument :tag_ids, [Integer], required: false
    end
  end