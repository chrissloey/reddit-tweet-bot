FROM ruby:2.1.2
MAINTAINER Chris Sloey

WORKDIR /bot

# Gems
RUN gem install bundler --no-ri --no-rdoc
ADD Gemfile /bot/Gemfile
ADD Gemfile.lock /bot/Gemfile.lock
RUN bundle install

# Code
ADD . /bot

CMD ["ruby", "bot.rb"]
