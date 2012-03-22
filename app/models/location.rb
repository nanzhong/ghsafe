class Location
  include MongoMapper::Document
  plugin Joint

  key :latitude,  Float
  key :longitude, Float
  key :date, Time
  key :address, String

  attachment :image

  belongs_to :route

end
