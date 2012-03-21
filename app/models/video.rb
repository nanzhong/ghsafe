class Video
  include MongoMapper::EmbeddedDocument
  plugin Joint

  key :start, Time
  key :end, Time

  attachment :data

  embedded_in :route

end
