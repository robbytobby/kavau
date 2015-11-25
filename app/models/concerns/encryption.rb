require 'active_support/concern'

module Encryption
  extend ActiveSupport::Concern

  class_methods do
    def encryption_key
      if Rails.env.production?
        # ENV['TOKEN_KEY] ||  raise 'Must set token key!!'
        raise 'Must set token key!!' unless ENV['TOKEN_KEY']
        ENV['TOKEN_KEY']
      else
        ENV['TOKEN_KEY'] ? ENV['TOKEN_KEY'] : 'test_key'
      end
    end
  end
end
