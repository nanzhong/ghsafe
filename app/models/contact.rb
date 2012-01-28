class Contact
  include MongoMapper::EmbeddedDocument

  key :first_name,  String
  key :last_name,   String
  key :email,       String, :required => true 
  key :phone,       Integer
end