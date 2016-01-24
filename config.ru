require_relative 'musicologica/rss'
require_relative 'hudebni_rozhledy/rss'

run Rack::URLMap.new(
      '/musicologica' => Musicologica::App.new,
      '/hudebnirozhledy' => HudebniRozhledy::App.new
    )
