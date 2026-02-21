class Traveler < ApplicationRecord
  belongs_to :insurance_policy

  validates :first_name, :last_name, :birth_date, :passport_number, :passport_country, presence: true
  validates :passport_country, length: { is: 2 }
end
