Rails.application.config.kavau_encryption_key = Base64.decode64(ENV['TOKEN_KEY'])
if Rails.env.production?
  raise 'Must set token key!!' unless ENV['TOKEN_KEY']
else
  Rails.application.config.kavau_encryption_key ||= 'TestKey' 
end
