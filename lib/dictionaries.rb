module Dictionaries
  def self.dictionaries
    constants.map { |sym| const_get(sym) }.select do |dictionary|
      dictionary.is_a?(Class) && !dictionary.const_get(:API_KEY).to_s.empty?
    end
  end
end
