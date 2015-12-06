class Letter < ActiveRecord::Base
  strip_attributes
  
  has_many :pdfs 

  validates :content, presence: true
  validates_numericality_of :year, only_integer: true, allow_blank: true

  def to_partial_path
    'letters/letter'
  end

  def pdfs_created?
    !pdfs_created_at.blank?
  end
end
