class NullBalance
  attr_reader :date

  def initialize(date)
    @date = date || Date.today
  end

  def end_amount
    0
  end

  def update_end_amount!
  end
end

