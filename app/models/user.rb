class User
  include MongoMapper::Document

  key :name,          String
  key :email,         String
  key :phone,         Integer
  key :device_token,  String

  many :contacts
  many :reports
  many :routes

  timestamps!

  validates_presence_of :email, :device_token
  validates_uniqueness_of :email, :device_token

end
