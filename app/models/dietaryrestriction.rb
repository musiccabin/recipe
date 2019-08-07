class Dietaryrestriction < ApplicationRecord

    belongs_to :user

    has_many :dietaryrestrictionlinks, dependent: :destroy
    has_many :myrecipes, through: :dietaryrestrictionlinks
    has_many :users, dependent: :nullify

    validates :name, presence: true, uniqueness: {case_sensitive: false}

    before_validation :downcase_name

    private
    def downcase_name
        self.name&.downcase!
    end
end
