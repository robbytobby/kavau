class Address < ApplicationRecord
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
end
