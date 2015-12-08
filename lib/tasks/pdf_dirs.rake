namespace :setup do
  desc "Create necessary pdf directories"
  task :pdf_dirs do
    translations["de"]["directories"].values.each do |name|
      mkdir_p "#{Rails.root}/public/system/#{name}"
    end
  end

  def locale
    Rails.application.config.i18n.default_locale.to_s
  end

  def translations
    YAML.load_file("#{Rails.root}/config/locales/#{locale}.yml")
  end
end
