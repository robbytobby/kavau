module PaymentsHelper
  def payment_type_options
    Payment.valid_types.map{ |type| [t(type.underscore, scope: 'activerecord.models'), type] }
  end
end
