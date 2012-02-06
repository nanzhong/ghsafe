class Report
  include MongoMapper::Document

  INVALID = -1
  MURDER  = 1
  ASSAULT = 2
  ROBBERY = 3
  UNEASY  = 4

  key :type,      Integer
  key :date,      Time
  key :latitude,  Float
  key :longitude, Float

  timestamps!

  validates_presence_of :type, :date, :latitude, :longitude
end
