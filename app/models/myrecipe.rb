class Myrecipe < ApplicationRecord

    belongs_to :user

    has_many :myrecipeingredientlinks, dependent: :destroy
    has_many :ingredients, through: :myrecipeingredientlinks
    has_many :completions, dependent: :destroy
    has_many :reviews, dependent: :destroy
    has_many :dietaryrestrictionlinks, dependent: :destroy
    has_many :dietaryrestrictions, through: :dietaryrestrictionlinks
    has_many :taggings, dependent: :destroy
    has_many :tags, through: :taggings
    has_many :myrecipemealplanlinks, dependent: :destroy
    has_many :mealplans, through: :myrecipemealplanlinks

    has_attached_file :avatar, styles: {custom: "500x500#", medium: "700x700#", thumb: "500x500#" }, default_url: "/images/:style/missing.png"
    validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

    validates :title, presence: true, uniqueness: true
    validates :cooking_time, presence: true
    validate :accepted_cooking_time
    validate :is_valid_URL
    validates :instructions, presence: true

    before_validation :unique_tags
    before_validation :unique_restrictions
    after_validation :convert_cooking_time

    def tag_names
        self.tags.map(&:name).join(", ")
    end

    def tag_names=(rhs)
        self.tags = rhs.strip.split(/\s*,\s*/).map do |tag_name|
            Tag.find_or_initialize_by(name: tag_name)
        end
    end

    def dietaryrestriction_names
        self.dietaryrestrictions.map(&:name).join(", ")
    end

    def dietaryrestriction_names=(rhs)
        self.dietaryrestrictions = rhs.strip.split(/\s*,\s*/).map do |dr_name|
            Dietaryrestriction.find_or_initialize_by(name: dr_name)
        end
    end

    private
    def convert_cooking_time
        input = cooking_time.gsub(/\s+/, "")
        output_in_min = 0
        if input.include? 'h'
            output_in_min += input[input.index('h') - 1].to_i * 60
            start_index = input.index('h') + 1
            end_index = input.length - 1
            input = input[start_index..end_index]
        end
        if input.include? 'm'
            output_in_min += input[0..(input.index('m') - 1)].to_i
        end
        self.cooking_time_in_min = output_in_min
    end
    
    def accepted_cooking_time
        # return if self.cooking_time = ''
        error_text = 'please follow the format of 1h5m or 5m, rounding to the nearest 5-minute. For 27 minutes, enter 25m. Note: enter 1h instead of 60m.'
        input = cooking_time.gsub(/\s+/, "")
        if input.include? 'h'
            self.errors.add(:cooking_time,error_text) unless input[0..(input.index('h') - 1)].to_i
            start_index = input.index('h') + 1
            end_index = input.length - 1
            input = input[start_index..end_index]
        end
        if input.include? 'm'
            self.errors.add(:cooking_time,error_text) unless ((input.index('m') == 2 || input.index('m') == 1) && input[0..(input.index('m') - 1)].to_i && input[0..(input.index('m') - 1)].to_i <= 55)
        end
    end

    def is_valid_URL
        if videoURL.present?
            self.errors.add(:videoURL,'we think the URL is not valid.') unless open(self&.videoURL).status == ["200", "OK"]
        end
    end

    def unique_tags
        self.tags == tags.reject{ |e| e.to_s.empty? }.uniq unless tags == nil
    end

    private
    def unique_restrictions
        self.dietaryrestrictions == dietaryrestrictions.reject(&:blank?).uniq unless dietaryrestrictions == nil
    end
end
