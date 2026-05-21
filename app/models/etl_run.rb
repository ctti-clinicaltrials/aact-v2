class EtlRun < ApplicationRecord
  has_many :steps, -> { order(:position) }, class_name: "EtlRunStep"
end
