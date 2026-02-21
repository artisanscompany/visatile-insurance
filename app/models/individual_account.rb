class IndividualAccount < ApplicationRecord
  has_one :account, as: :accountable, dependent: :destroy, touch: true
end
