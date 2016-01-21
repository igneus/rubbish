#!/usr/bin/ruby

# musicologica.cz misses a rss feed;
# they don't seem to be going to add one (I have asked repeatedly);
# I am used to read the website using a rss reader ...

require 'uri'
require 'net/http'
require 'rss'

require 'nokogiri'
require 'nyny'

module Musicologica
  Article = Struct.new(:link, :title, :published_at)

  # knows how to find new articles on the homepage
  class MusicologicaHomepageArticles
    def initialize(uri, document)
      @uri = uri
      @doc = document
    end

    def each
      article_nodes.each do |article|
        yield Article.new(
                link(article),
                title(article),
                published_at(article)
              )
      end
    end

    def article_nodes
      @doc.css '.article-item-list-allArticle .article-item-list-allArticle-text'
    end

    def link(article)
      href = article.css('h2 a')[0]['href']
      if href.start_with? 'http'
        href
      else
        @uri + href
      end
    end

    def title(article)
      article.css('h2').text.strip
    end

    def published_at(article)
      str = article.css('.date').text.match(/\d+\s*\.\d+\s*\.\d+/)[0].gsub(' ', '')
      Time.strptime(str, '%d.%m.%Y')
    end
  end

  def self.build_rss(articles)
    RSS::Maker.make('2.0') do |maker|
      maker.channel.language = 'cs'
      maker.channel.updated = Time.now.to_s
      maker.channel.link = 'http://yakub.cz/cgi-bin/musicologica_rss.cgi'
      maker.channel.title = 'Musicologica.cz unofficial rss feed'
      maker.channel.description = 'With love, igneus'

      articles.each do |article|
        maker.items.new_item do |item|
          item.link = article.link
          item.title = article.title
          item.updated = article.published_at
        end
      end
    end
  end

  class App < NYNY::Base
    get '/' do
      redirect_to '/musicologica/rss'
    end

    get '/rss' do
      uri = URI('http://www.musicologica.cz/')
      response = Net::HTTP.get_response uri
      doc = Nokogiri::HTML response.body
      articles = MusicologicaHomepageArticles.new uri, doc

      headers['Content-Type'] = 'application/rss+xml'
      Musicologica.build_rss articles
    end
  end
end