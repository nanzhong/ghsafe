class Location
  include MongoMapper::EmbeddedDocument

  key :latitude,  Float
  key :longitude, Float

end
