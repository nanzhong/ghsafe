class Report
  include MongoMapper::Document

  key :type,      ReportType
  key :date,      Time
  key :latitude,  Float
  key :longitude, Float

  belongs_to :user

  timestamps!

  validates_presence_of :type, :date, :latitude, :longitude
end
