module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :email, String, null: true
    field :password_digest, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
    # field :avatar_file_name, String, null: true
    # field :avatar_content_type, String, null: true
    # field :avatar_file_size, Integer, null: true
    # field :avatar_updated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :is_admin, Boolean, null: true
    field :city, String, null: true
    field :province, String, null: true
    field :region, String, null: true
    field :postal, String, null: true
  end
end
