module FundsHelper
  def limit_options
    Fund.valid_limits.map{ |limit| [t(limit.underscore, scope: 'fund_limits'), limit] }
  end
end
