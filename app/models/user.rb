class User
  include MongoMapper::Document

  key :first_name,    String
  key :last_name,     String
  key :email,         String
  key :phone,         Integer
  key :device_token,  String

  many :contacts

  timestamps!

  validates_presence_of :name, :email, :device_token
  validates_uniqueness_of :email, :device_token

end
