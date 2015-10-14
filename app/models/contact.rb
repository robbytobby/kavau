class Contact < Address
  belongs_to :organization, class_name: Address, foreign_key: :organization_id
  validates_presence_of :first_name, :name

  def to_partial_path
    "addresses/contact"
  end

end
