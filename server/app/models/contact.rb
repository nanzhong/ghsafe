class Contact
  include MongoMapper::EmbeddedDocument

  key :name,  String
  key :email, String, :required => true 
  key :phone, Integer

  belongs_to :user

end
