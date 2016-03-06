if Rails.env.production?
  raise 'Must set token key!!' unless ENV['TOKEN_KEY']
  Rails.application.config.kavau_encryption.key = ENV['TOKEN_KEY']
else
  Rails.application.config.kavau_encryption_key = 'test_key'
end
