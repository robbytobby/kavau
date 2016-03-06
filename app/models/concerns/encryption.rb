require 'active_support/concern'

module Encryption
  extend ActiveSupport::Concern

  class_methods do
    def encryption_key
      Rails.application.config.kavau_encryption_key
    end
  end
end
