class Discount < ApplicationRecord
  belongs_to :merchant

  validates_presence_of :percent,
                        :min_qty

end