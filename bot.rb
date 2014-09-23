#!/usr/bin/env ruby

require 'rubygems'
require 'chatterbot/dsl'
require 'redd'

logfile = File.open('/bot/log/bot.log', File::WRONLY | File::APPEND)
logger = Logger.new(logfile)
logger.debug "Initializing bot #{ENV['THRESHOLD']}..."
delay = 600 # Delay on first startup to prevent spamming
sleep delay

# Setup twitter
consumer_key ENV['CONSUMER_KEY']
consumer_secret ENV['CONSUMER_SECRET']

secret ENV['SECRET']
token ENV['TOKEN']

# Setup reddit
reddit = Redd::Client::Authenticated.new_from_credentials ENV['REDDIT_USERNAME'],
  ENV['REDDIT_PASSWORD'], user_agent: "#{ENV['REDDIT_USERNAME']} bot v1.0"

# remove this to update the db
no_update

# Links are 23 chars, how big can our title be?
TWEET_LENGTH = 140
COMMENTS_LINK_LENGTH = 26 # space, 2 brackets, link
ARTICLE_LINK_LENGTH = 24 # space, link

THRESHOLD = ENV['THRESHOLD'].to_i

logger.debug "... initialized"

loop do
  logger.debug "Fetching posts"
  hot_posts = reddit.get_hot(ENV['SUBREDDIT'])
  if hot_posts
    logger.debug "Got #{hot_posts.count} hot posts"
    posts = hot_posts.select {|p| p.score > THRESHOLD && !p.saved}
    logger.debug "Got #{posts.count} posts to tweet"
    posts.each do |post|
      logger.debug "Tweeting post #{post.title}"

      # How big can the title be?
      max_title_length = TWEET_LENGTH - ARTICLE_LINK_LENGTH
      if post.self?
        max_title_length -= COMMENTS_LINK_LENGTH
      end

      # Truncate title if necessary
      title = post.title
      if title.length > max_title_length
        title = "#{title[0..max_title_length-1]}..."
      end

      # Tweet then save so that we don't tweet it again
      if post.self?
        tweet "#{title} #{post.url}"
      else
        tweet "#{title} #{post.url} (#{post.permalink})"
      end

      logger.debug "Tweeted post #{post.title}"

      # Mark as saved to prevent tweeting again
      logger.debug "saving #{post.title}"
      post.save
      sleep 120 + rand(120) + delay
    end
  end

  sleep 120 + rand(480) + delay
  delay /= 2
end
