Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static file server for tests with Cache-Control for performance.
  config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Randomize the order test cases are executed.
  config.active_support.test_order = :random

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.after_initialize do
    Rails.configuration.x.kavau_custom.pdf = {
      :colors=>{:color3=>"7c7b7f", :color1=>"009dc3", :color2=>"f9b625"}, 
      :margins=>{:bottom_margin=>3.5, :top_margin=>3.5, :right_margin=>2.0, :left_margin=>2.5}, 
      :templates=>{
        :logo=>"#{Rails.root}/spec/support/templates/logo.png", 
        :watermark=>"#{Rails.root}/spec/support/templates/stempel.png", 
        :first_page_template=>nil, 
        :following_page_template=>nil
      }, 
      :custom_font=>{
        :normal=>"#{Rails.root}/public/fonts/infotext_normal.ttf", 
        :italic=>"#{Rails.root}/public/fonts/infotext_italic.ttf", 
        :bold=>"#{Rails.root}/public/fonts/infotext_bold.ttf", 
        :bold_italic=>"#{Rails.root}/public/fonts/infotext_bold_italic.ttf",
      }, 
      :content=>{
        :saldo_information=>"additional information"
      }
    }

    Rails.configuration.x.kavau_custom.general = {:project_name=>"LaMa", :website_url=>"www.lamakat.de"}

    Rails.configuration.x.kavau_custom.legal_regulation = {enforce_bagatelle_limits: true, utilize_transitional_regulation: true}
  end
end
