class Address < ActiveRecord::Base
  include AsSpreadsheet
  strip_attributes
  delegate :human_salutation, :country_name, :legal_form,  to: :presented, prefix: true

  scope :creditors, -> { where(type: ['Person', 'Organization']) }
  scope :project_addresses, -> { where(type: 'ProjectAddress') }

  validates :email, email: true, allow_blank: true

  def to_partial_path
    'addresses/address'
  end

  def list_action_partial_path
    'addresses/list_actions'
  end

  def person?
    type == 'Person'
  end

  def project_address?
    type == 'ProjectAddress'
  end
  alias_method :belongs_to_project?, :project_address?

  def organization?
    type == 'Organization'
  end

  def contact?
    type == 'Contact'
  end

  def creditor?
    organization? || person?
  end

  private
  def spreadsheet_values
    [:id, :presented_human_salutation, :title, :name, :first_name, :presented_legal_form, :street_number, :zip, :city, :presented_country_name, :email, :phone, :notes]
  end
end
