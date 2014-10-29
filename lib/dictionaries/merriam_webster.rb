module Dictionaries
  class MerriamWebster
    API_KEY = ENV["MERRIAM_WEBSTER_API_KEY"]

    def initialize(word)
      @word = word

      http_response = Redis.current.get("dictionary.merriamwebster.#{@word}") if Redis.current.connected?

      unless http_response
        http_response = RestClient.get "http://www.dictionaryapi.com/api/v1/references/collegiate/xml/#{word}?key=#{API_KEY}"
        Redis.current.set("dictionary.merriamwebster.#{@word}", http_response) if Redis.current.connected?
      end

      @details = Nokogiri::XML(http_response)
    rescue
      @details = nil
    end

    def pronunciation
      return if @details.nil?
      return @pronunciation if defined?(@pronunciation)

      filename = @details.css("wav").first.text

      if filename.starts_with?(*("0".."9").to_a)
        prefix = "number"
      elsif filename.starts_with?("bix")
        prefix = "bix"
      elsif filename.starts_with?("gg")
        prefix = "gg"
      else
        prefix = filename[0]
      end

      @pronunciation = "http://media.merriam-webster.com/soundc11/#{prefix}/#{filename}"
    rescue
      @pronunciation = nil
    end
  end
end
