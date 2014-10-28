namespace :elasticsearch do
  task :index => :environment do
    path = ENV["ELASTIC_SEARCH_PATH"].to_s
    index = ENV["ELASTIC_SEARCH_INDEX"].to_s
    return if path.empty? || index.empty?

    begin
      RestClient.delete "#{path}/#{index}"
    rescue
    end

    attributes = [:word, :definition, :synonyms, :antonyms, :sentence]

    payload = Card.all.map do |card|
      { :index => { :_id => card.id } }.to_json + "\n" +
      card.to_json(*attributes)
    end.join("\n")

    RestClient.put "#{path}/#{index}/card/_bulk", payload
  end
end
