class KavauDeviseMailer < Devise::Mailer
  helper :application 
  include Devise::Controllers::UrlHelpers 
  default template_path: 'devise/mailer', from: Proc.new{ Setting.kavau.mailer[:devise][:mailer_sender] }
end
