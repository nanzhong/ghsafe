class Location
  include MongoMapper::EmbeddedDocument
  plugin Joint

  key :latitude,  Float
  key :longitude, Float
  key :date, Time

  attachment :image

  embedded_in :route

end
