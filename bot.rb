#!/usr/bin/env ruby

require 'rubygems'
require 'chatterbot/dsl'
require 'redd'

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

loop do
  puts "Fetching posts"
  posts = reddit.get_hot(ENV['SUBREDDIT']).select {|p| p.score > THRESHOLD && !p.saved}
  puts "Got #{posts.count} posts to tweet"
  posts.each do |post|
    puts "Found #{post.title}"

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

    # Mark as saved to prevent tweeting again
    post.save
  end

  sleep 60
end
