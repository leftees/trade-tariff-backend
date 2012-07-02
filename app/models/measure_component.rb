class MeasureComponent < ActiveRecord::Base
  self.primary_key = [:record_code, :subrecord_code, :record_sequence_number]
  
  belongs_to :measure, foreign_key: :measure_sid
  belongs_to :measurement, foreign_key: [:measurement_unit_code, :measurement_unit_qualifier_code]
  belongs_to :duty_expression
  belongs_to :monetary_unit, foreign_key: :monetary_unit_code
end
