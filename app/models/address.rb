class Address < ActiveRecord::Base
  strip_attributes 
  scope :creditors, -> { where(type: ['Person', 'Organization']) }

  def to_partial_path
    "addresses/address"
  end

  def person?
    type == 'Person'
  end

  def project_address?
    type == 'ProjectAddress'
  end

  def organization?
    type == 'Organization'
  end

  def project_address?
    type == 'ProjectAddress'
  end

  def creditor?
    organization? || person?
  end
end

