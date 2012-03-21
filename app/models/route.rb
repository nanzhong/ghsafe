class Route
  include MongoMapper::Document

  key :date, Time

  many :locations
  belongs_to :user

  timestamps!
end
