require 'active_support/concern'

module DateScopes
  extend ActiveSupport::Concern

  included do
    scope :before, ->(to_date){ where( self.arel_table[:date].lt(to_date) ) }
    scope :before_inc, ->(to_date){ where( self.arel_table[:date].lteq(to_date) ) }
    scope :after, ->(from_date){ where( self.arel_table[:date].gt(from_date) ) }
    scope :after_inc, ->(from_date){ where( self.arel_table[:date].gteq(from_date) ) }
    scope :this_year_upto, ->(to_date){ before_inc(to_date).after_inc(to_date.beginning_of_year) }
  end
end
