class Location
  include MongoMapper::EmbeddedDocument

  key :latitude,  Float
  key :longitude, Float

  belongs_to :route

end
