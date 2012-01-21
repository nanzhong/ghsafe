class Route
  include MongoMapper::Document

  key :date, Time

  many :locations

  timestamps!
end
