task :stats => "kv:stats"
namespace :kv do
  task :stats do
    require 'rails/code_statistics'
    ::STATS_DIRECTORIES << ["PDFs", "app/pdfs"]
    ::STATS_DIRECTORIES << ["Policies", "app/policies"]
    ::STATS_DIRECTORIES << ["Presenters", "app/presenters"]
    ::STATS_DIRECTORIES << ["Validators", "app/validators"]
  end
end
