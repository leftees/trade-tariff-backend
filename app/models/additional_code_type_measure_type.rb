class AdditionalCodeTypeMeasureType < ActiveRecord::Base
  set_primary_keys :measure_type_id, :additional_code_type_id

  belongs_to :measure_type
  belongs_to :additional_code_type
end

# == Schema Information
#
# Table name: additional_code_type_measure_types
#
#  record_code             :string(255)
#  subrecord_code          :string(255)
#  record_sequence_number  :string(255)
#  measure_type_id         :string(255)
#  additional_code_type_id :string(255)
#  validity_start_date     :date
#  validity_end_date       :date
#  created_at              :datetime
#  updated_at              :datetime
#

