module Mutations
  class SignOutMutation < Mutations::BaseMutation
    field :status, String, null: false

    def resolve
      return { status: "no user is signed in" } unless current_user

      # byebug

      context[:session][:token] = nil
      context[:current_user] = nil
      { status: 'user signed out!' }
    end
  end
end