class Address < ActiveRecord::Base
  include AsCsv
  strip_attributes

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

  def self.csv_columns
    [:id, :human_salutation, :title, :name, :first_name, :street_number, :zip, :city, :country_name, :legal_form]
  end
end
