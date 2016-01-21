require_relative 'musicologica/rss'

run Rack::URLMap.new("/musicologica" => Musicologica::App.new)
