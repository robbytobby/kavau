Rails.application.config.kavau_encryption_key = ENV['TOKEN_KEY']
if Rails.env.production?
  raise 'Must set token key!!' unless ENV['TOKEN_KEY']
else
  Rails.application.config.kavau_encryption_key ||= 'TestKey' 
  #Rails.application.config.kavau_encryption_key = 'ba9ed2d9834a884b23895dc27cd8e9de54e320dd1530af3d537fb26976e387caaac4d0236c3acce6bc33d23f1df1d7818fc641cda70447815ad6a83203b560af'
end
