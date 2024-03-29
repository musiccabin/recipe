class Dietaryrestriction < ApplicationRecord

    has_many :dietaryrestrictionlinks, dependent: :destroy
    has_many :myrecipes, through: :dietaryrestrictionlinks
    has_many :dietaryrestrictionlinks, dependent: :destroy
    has_many :users, through: :userdietaryrestrictionlinks

    validates :name, presence: true, uniqueness: {case_sensitive: false}

    before_validation :downcase_name

    private
    def downcase_name
        self.name&.downcase!
    end
end
