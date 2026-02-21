class PolicyCompleted < ApplicationRecord
  include PolicyState

  validates :pdf_path, presence: true
end
