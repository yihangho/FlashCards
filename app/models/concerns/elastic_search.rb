module ElasticSearch
  extend ActiveSupport::Concern

  included do
    after_save { elastic_search_index }
  end

  def self.search_enabled?
    !ENV["ELASTIC_SEARCH_PATH"].to_s.empty? && ! ENV["ELASTIC_SEARCH_INDEX"].to_s.empty?
  end

  def elastic_search_index
    return unless ElasticSearch.search_enabled?

    json = Hash[self.class.elastic_search_attributes.map { |attr| [attr, send(attr)]}].to_json

    RestClient.put self.class.elastic_search_url(id), json
  end

  module ClassMethods
    def search(query)
      return [] unless ElasticSearch.search_enabled?

      payload = {
        :fields => [],
        :query => {
          :query_string => {
            :query => query
          }
        }
      }.to_json

      response = JSON.parse(RestClient.post(elastic_search_url("_search"), payload))
      ids = response["hits"]["hits"].map { |h| h["_id"].to_i }

      find(ids).sort { |a, b| ids.index(a.id) <=> ids.index(b.id) }
    end

    def elastic_search_attributes(*attrs)
      if attrs.length == 0
        @elastic_search_attributes ||= attribute_names
      else
        @elastic_search_attributes = attrs.map(&:to_s)
      end
    end

    def elastic_search_url(action="")
      path = ENV["ELASTIC_SEARCH_PATH"]
      index = ENV["ELASTIC_SEARCH_INDEX"]
      "#{path}/#{index}/#{model_name.singular}/#{action}"
    end

    def elastic_search_reindex_all
      return [] unless ElasticSearch.search_enabled?

      begin
        RestClient.delete elastic_search_url
      rescue
      end

      payload = all.map do |obj|
        { :index => { :_id => obj.id } }.to_json + "\n" +
        Hash[elastic_search_attributes.map { |attr| [attr, obj.send(attr)]}].to_json
      end.join("\n")

      RestClient.put elastic_search_url("_bulk"), payload
    end
  end
end
