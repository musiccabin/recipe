module Types
    class UserAttributes < Types::BaseInputObject
      description "Attributes for creating or updating a user"

      argument :first_name, String, required: false
      argument :last_name, String, required: false
      argument :email, String, required: false
      argument :password_digest, String, required: false
      argument :avatar_file_name, String, required: false
      argument :avatar_content_type, String, required: false
      argument :avatar_file_size, Integer, required: false
      argument :avatar_updated_at, GraphQL::Types::ISO8601DateTime, required: false
      argument :is_admin, Boolean, required: false
      argument :city, String, required: false
      argument :province, String, required: false
      argument :region, String, required: false
      argument :postal, String, required: false
    end
  end