require 'active_support/concern'

module Encryption  
  extend ActiveSupport::Concern

  class_methods do
    def encryption_key
      # if in production. require key to be set.
      if Rails.env.production?
        raise 'Must set token key!!' unless ENV['TOKEN_KEY']
        ENV['TOKEN_KEY']
      else
        ENV['TOKEN_KEY'] ? ENV['TOKEN_KEY'] : 'test_key'
      end
    end
  end
end  
