class Letter < ActiveRecord::Base
  strip_attributes
  
  has_many :pdfs, dependent: :restrict_with_exception 

  validates :content, presence: true
  validates_numericality_of :year, only_integer: true, allow_blank: true

  def to_partial_path
    'letters/letter'
  end

  def pdfs_created?
    !pdfs_created_at.blank?
  end

  def termination_letter?
    is_a?(TerminationLetter)
  end

  def balance_letter?
    is_a?(BalanceLetter)
  end

  def standard_letter?
    is_a?(StandardLetter)
  end
end
