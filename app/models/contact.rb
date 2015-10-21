class Contact < Address
  belongs_to :institution, class_name: Address, foreign_key: :institution_id

  before_save :set_institution_type

  validates_presence_of :first_name, :name

  def to_partial_path
    "addresses/contact"
  end

  private
    def set_institution_type
      self.institution_type = institution.class.to_s
    end
end
