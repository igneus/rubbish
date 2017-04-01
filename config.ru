require_relative 'musicologica/rss'
require_relative 'hudebni_rozhledy/rss'
require_relative 'varhanici/rss'

run Rack::URLMap.new(
      '/musicologica' => Musicologica::App.new,
      '/hudebnirozhledy' => HudebniRozhledy::App.new,
      '/varhanici' => Varhanici::App.new,
    )
