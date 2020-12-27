module Types
    class UserAttributes < Types::BaseInputObject
      description "Attributes for creating or updating a user"

      argument :id, ID, required: false
      argument :first_name, String, required: false
      argument :last_name, String, required: false
      # argument :email, String, required: true
      # argument :password_digest, String, required: true
    #   argument :avatar_file_name, String, null: true
    #   argument :avatar_content_type, String, null: true
    #   argument :avatar_file_size, Integer, null: true
    #   argument :avatar_updated_at, GraphQL::Types::ISO8601DateTime, null: true
      # argument :is_admin, Boolean, required: true
      argument :city, String, required: false
      argument :province, String, required: false
      argument :region, String, required: false
    end
  end