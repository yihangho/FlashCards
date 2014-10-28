namespace :elasticsearch do
  task :index => :environment do
    Card.elastic_search_reindex_all
  end
end
