source 'https://rubygems.org'

gemspec

gem 'hiera'

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
