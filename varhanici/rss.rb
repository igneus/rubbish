#!/usr/bin/ruby

# rss of comments in the varhanici.org guestbook

require 'uri'
require 'net/http'

require 'nokogiri'
require 'nyny'

require_relative '../lib/articles_rss'

module Varhanici
  # knows how to find new articles on the homepage
  class GuestBookPosts
    def initialize(uri, document)
      @uri = uri
      @doc = document
    end

    def self.create_articles
      uri = URI('http://www.varhany.org/khostu.php')
      response = Net::HTTP.get_response uri
      doc = Nokogiri::HTML response.body
      articles = new uri, doc
    end

    def each
      article_nodes.each do |article|
        yield ArticlesRSS::Article.new(
                link(article),
                title(article),
                published_at(article),
                text(article)
              )
      end
    end

    def article_nodes
      @doc.css('table.knd')
    end

    def link(article)
      @uri.to_s
    end

    def title(article)
      article.css('b').text.strip
    end

    def published_at(article)
      str = article.css('td[align="right"]').text.strip
      begin
        Time.strptime(str, '%d. %m. %Y, %H:%M')
      rescue ArgumentError
        Time.new
      end
    end

    def text(article)
      article.next_element.text.strip
    end
  end

  class App < NYNY::Base
    get '/' do
      redirect_to '/varhanici/rss'
    end

    get '/rss' do
      headers['Content-Type'] = ArticlesRSS::RSS_CONTENT_TYPE
      ArticlesRSS.build GuestBookPosts.create_articles,
                        feed_uri: request.url,
                        title: 'Varhanici Online Guestbook Posts',
                        description: 'fresh posts from the fabulous guestbook'
    end
  end
end
