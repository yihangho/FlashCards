load Rails.root.join("lib", "dictionaries.rb")
Dir[Rails.root.join("lib", "dictionaries", "*.rb")].each { |file| load file }
