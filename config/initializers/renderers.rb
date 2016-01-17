ActionController::Renderers.add :csv do |object, options|
  filename = options[:filename] || 'data'
  csv_string = CSV.generate(col_sep: "\t") do |csv|
    csv << options[:header] if options[:header]
    object.each do |element|
      csv << element.to_csv
    end
  end

  send_data csv_string, type: Mime::CSV,
    disposition: "attachment; filename=#{filename}.csv"
end
