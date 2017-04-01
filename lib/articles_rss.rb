require 'rss'

module ArticlesRSS
  Article = Struct.new(:link, :title, :published_at, :description)

  RSS_CONTENT_TYPE = 'application/rss+xml'

  def self.build(articles, feed_uri:, title:, description:)
    RSS::Maker.make('2.0') do |maker|
      maker.channel.language = 'cs'
      maker.channel.updated = Time.now.to_s
      maker.channel.link = feed_uri
      maker.channel.title = title
      maker.channel.description = description

      articles.each do |article|
        maker.items.new_item do |item|
          item.link = article.link
          item.title = article.title
          item.updated = article.published_at
          item.description = article.description
        end
      end
    end
  end
end
