class Grocery < ApplicationRecord
    has_many :ingredients

    belongs_to :user

    validates :name, presence: true, uniqueness: {scope: :user}
    validates_inclusion_of :category, :in => ['produce', 'meat', 'dairy', 'frozen', 'other'], :allow_nil => true
    # validates :quantity, presence: true
end
