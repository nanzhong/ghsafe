class Report
  include MongoMapper::Document

  key :type,      ReportType
  key :date,      Time
  key :latitude,  Float
  key :longitude, Float

  timestamps!

  validates_presence_of :type, :date, :latitude, :longitude
end
