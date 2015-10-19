class Contact < Address
  belongs_to :institution, polymorphic: true

  validates_presence_of :first_name, :name

  def to_partial_path
    "addresses/contact"
  end

end
