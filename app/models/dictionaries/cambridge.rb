module Dictionaries
  class Cambridge
    API_KEY = ENV["CAMBRIDGE_API_KEY"]

    def initialize(word)
      @word = word

      http_response = RestClient.get("https://dictionary.cambridge.org/api/v1/dictionaries/american-english/search?q=#{word}&pagesize=1", header)
      response = JSON.parse(http_response)

      if response["resultNumber"] > 0
        @entryId = response["results"].first["entryId"]
      else
        @entryId = nil
      end
    rescue
      @entryId = nil
    end

    def pronunciation
      return @pronunciation if defined?(@pronunciation)
      return @definition = nil unless @entryId

      http_response = RestClient.get("https://dictionary.cambridge.org/api/v1/dictionaries/american-english/entries/#{@entryId}/pronunciations?lang=us&format=mp3", header)
      response = JSON.parse(http_response)

      if response.empty?
        @pronunciation = nil
      else
        @pronunciation = response.first["pronunciationUrl"]
      end
    rescue
      @pronunciation = nil
    end

    def definition
      return @definition if defined?(@definition)
      return @definition = nil unless @entryId

      http_response = RestClient.get("https://dictionary.cambridge.org/api/v1/dictionaries/american-english/entries/#{@entryId}?format=xml", header)
      response = JSON.parse(http_response)
      xml_content = response["entryContent"]
      content = Nokogiri::XML(xml_content)
      @definition = content.css("def").first.text
    rescue
      @definition = nil
    end

    private

    def header(extra={})
      {:accessKey => API_KEY}.merge(extra)
    end
  end
end
