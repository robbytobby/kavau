require 'active_support/concern'

module Encryption
  extend ActiveSupport::Concern

  class_methods do
    def encryption_key
      ENV['TOKEN_KEY'] || Rails.env.production? ? raise('Must set token key!!') : 'test_key'
    end
  end
end
