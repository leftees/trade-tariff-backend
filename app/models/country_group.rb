class CountryGroup
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,        type: String
  field :description, type: String

  has_and_belongs_to_many :countries
  has_many :measures, as: :region

  def class_name
    self.class.name
  end

  def to_s
    name
  end
end
