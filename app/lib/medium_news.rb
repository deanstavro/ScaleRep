require 'rss'
require 'open-uri'

module Medium_News
	def self.medium_news
		rss = RSS::Parser.parse(open('https://medium.com/feed/@ScaleRep').read, false).items[0..5]
		rss.map{|article| 
			{title: article.title, date: article.pubDate, link: article.link, description: article.description, creator: article.dc_creator, img: article.content_encoded.split("figure")[1].to_s.split('"')[3] }}
	end
end
