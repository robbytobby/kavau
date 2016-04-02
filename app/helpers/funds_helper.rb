module FundsHelper
  def limit_options
    Fund.valid_limits.map{ |limit| [t(limit.underscore, scope: 'fund_limits'), limit] }
  end

  def project_address_options
    ProjectAddress.all.map{ |pa| [ProjectAddressPresenter.new(pa, nil).full_name, pa.id] }
  end
end
