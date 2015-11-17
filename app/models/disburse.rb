class Disburse < Payment
  before_save :set_sign

  private
    def set_sign
      self.sign = -1
    end
end
