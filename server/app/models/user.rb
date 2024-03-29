class User
  include MongoMapper::Document

  key :name,          String
  key :email,         String
  key :phone,         String
  key :device_token,  String

  many :contacts
  many :reports
  many :routes

  timestamps!

  validates_presence_of :name, :email, :device_token
  validates_uniqueness_of :email, :device_token

end
