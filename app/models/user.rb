class User < ApplicationRecord

    has_secure_password
    has_many :groceries, dependent: :destroy
    has_many :dietary_restrictions, dependent: :destroy
    has_many :likes, dependent: :nullify
    has_many :favourites, dependent: :delete
    has_many :completions, dependent: :nullify
    has_many :reviews, dependent: :nullify

    VALID_EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    validates :email, presence: true, uniqueness: true, format: VALID_EMAIL_REGEX
    validates :first_name, presence: true
    validates :last_name, presence: true

    has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
    validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
end
