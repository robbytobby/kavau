Kavau::Application.config.secret_key_base = ENV['SECRET_KEY_BASE']
Kavau::Application.config.secret_key_base ||= ('x' * 30) if Rails.env.development? or Rails.env.test?
