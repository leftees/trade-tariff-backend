class Language < Sequel::Model
  set_primary_key  :language_id

  ######### Conformance validations 130
  # LA2 - TODO
  def validate
    super
    # LA1
    validates_unique(:language_id)
    # LA3
    validates_start_date
  end
  
  # has_many :language_descriptions
  # has_many :additional_code_descriptions
  # has_many :additional_code_type_descriptions
  # has_many :certificate_descriptions
  # has_many :certificate_type_descriptions
  # has_many :duty_expression_descriptions
  # has_many :export_refund_nomenclature_descriptions
  # has_many :footnote_descriptions
  # has_many :footnote_type_descriptions
  # has_many :geographical_area_descriptions
  # has_many :geographical_area_group_descriptions, foreign_key: :parent_geographical_area_group_sid,
  #                                                 class_name: 'GeographicalArea'
  # has_many :language_descriptions
  # has_many :measure_action_descriptions
  # has_many :measure_condition_code_descriptions
  # has_many :measure_type_descriptions
  # has_many :measure_type_series_descriptions
  # has_many :measurement_unit_descriptions
  # has_many :measurement_unit_qualifier_descriptions
  # has_many :meursing_heading_texts
  # has_many :monetary_unit_descriptions
  # has_many :regulation_group_descriptions
  # has_many :regulation_role_type_descriptions
  # has_many :transmission_comments
  # has_many :goods_nomenclature_descriptions
  # has_many :goods_nomenclature_group_descriptions
end


