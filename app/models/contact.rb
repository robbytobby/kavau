class Contact < Address
  strip_attributes

  belongs_to :institution, class_name: Address, foreign_key: :institution_id

  before_save :set_institution_type

  validates_presence_of :first_name, :name

  def list_action_partial_path
    'addresses/contact_list_actions'
  end

  private
    def set_institution_type
      self.institution_type = institution.class.to_s
    end
end
