module Dictionaries
  class Cambridge
    API_KEY = ENV["CAMBRIDGE_API_KEY"]

    def initialize(word)
      @word = word

      if Redis.current.connected?
        entryId = Redis.current.get("dictionary.cambridge.#{@word}.entryid")
        return @entryId = entryId unless entryId.nil?
      end

      http_response = RestClient.get("https://dictionary.cambridge.org/api/v1/dictionaries/american-english/search?q=#{word}&pagesize=1", header)
      response = JSON.parse(http_response)

      if response["resultNumber"] > 0
        @entryId = response["results"].first["entryId"]
        Redis.current.set("dictionary.cambridge.#{@word}.entryid", @entryId) if Redis.current.connected?
      else
        @entryId = nil
      end
    rescue
      @entryId = nil
    end

    def pronunciation
      return @pronunciation if defined?(@pronunciation)
      return @pronunciation = nil unless @entryId

      if Redis.current.connected?
        pronunciation = Redis.current.get("dictionary.cambridge.#{@word}.pronunciation")
        return @pronunciation = pronunciation unless pronunciation.nil?
      end

      http_response = RestClient.get("https://dictionary.cambridge.org/api/v1/dictionaries/american-english/entries/#{@entryId}/pronunciations?lang=us&format=mp3", header)
      response = JSON.parse(http_response)

      if response.empty?
        @pronunciation = nil
      else
        @pronunciation = response.first["pronunciationUrl"]
        Redis.current.set("dictionary.cambridge.#{@word}.pronunciation", @pronunciation) if Redis.current.connected?
        @pronunciation
      end
    rescue
      @pronunciation = nil
    end

    def definition
      return @definition if defined?(@definition)
      return @definition = nil unless @entryId

      if Redis.current.connected?
        pronunciation = Redis.current.get("dictionary.cambridge.#{@word}.definition")
        return @pronunciation = pronunciation if pronunciation.nil?
      end

      http_response = RestClient.get("https://dictionary.cambridge.org/api/v1/dictionaries/american-english/entries/#{@entryId}?format=xml", header)
      response = JSON.parse(http_response)
      xml_content = response["entryContent"]
      content = Nokogiri::XML(xml_content)
      @definition = content.css("def").first.text
      Redis.current.set("dictionary.cambridge.#{@word}.definition", @definition) if Redis.current.connected?
      @definition
    rescue
      @definition = nil
    end

    private

    def header(extra={})
      {:accessKey => API_KEY}.merge(extra)
    end
  end
end
