lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'bundler/version'

Gem::Specification.new do |s|
  s.name        = "hiera-file"
  s.version     = '0.0.2'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Hunter Haugen", "Adrien Thebo", "Reid Vandewiele"]
  s.homepage    = "http://github.com/adrienthebo/hiera-file"
  s.summary     = "File backend for Hiera"
  s.description = "A data backend for Hiera that can return the content of whole files"

  s.files        = Dir.glob("lib/**/*")
  s.require_path = 'lib'
end
