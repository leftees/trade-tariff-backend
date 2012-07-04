class MeasureType < ActiveRecord::Base
  set_primary_keys :measure_type_id

  has_one :description, foreign_key: :measure_type_id,
                        class_name: 'MeasureTypeDescription'
  has_many :measures, foreign_key: :measure_type
  has_many :additional_code_type_measure_types
  has_many :additional_code_types, through: :additional_code_type_measure_types
end

# == Schema Information
#
# Table name: measure_types
#
#  record_code                       :string(255)
#  subrecord_code                    :string(255)
#  record_sequence_number            :string(255)
#  measure_type_id                   :integer(4)
#  validity_start_date               :date
#  validity_end_date                 :date
#  trade_movement_code               :integer(4)
#  priority_code                     :integer(4)
#  measure_component_applicable_code :integer(4)
#  origin_dest_code                  :integer(4)
#  order_number_capture_code         :integer(4)
#  measure_explosion_level           :integer(4)
#  measure_type_series_id            :string(255)
#  created_at                        :datetime
#  updated_at                        :datetime
#

