class Route
  include MongoMapper::Document

  key :date, Time

  many :locations
  many :videos

  belongs_to :user

  timestamps!
end
