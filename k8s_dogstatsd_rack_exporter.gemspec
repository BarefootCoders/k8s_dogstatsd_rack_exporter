$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rack/middleware/dogstatsd_exporter/version"

Gem::Specification.new do |s|
  s.name = "k8s_dogstatsd_rack_exporter"
  s.version = Rack::DogstatsdExporter::VERSION

  s.authors = ["Jason Berlinsky"]

  s.summary = "Rack middleware to export simple request statistics to (dog)statsd"
  s.description = "Rack middleware to export simple request statistics to (dog)statsd"
  s.email = "jason@barefootcoders.com"

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.require_paths = ['lib']
  s.licenses = ["MIT"]

  s.add_runtime_dependency 'dogstatsd-ruby'
end
