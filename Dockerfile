FROM ruby:2.3

RUN gem install bundler
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

WORKDIR /app
RUN bundle install

ADD . /app
COPY ./config/database.yml.docker /app/config/database.yml

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.3.0/wait /wait

ENV RAILS_ENV production
ENV RACK_ENV production
ENV DOCKER true

RUN bundle exec rake assets:precompile

CMD /wait && bundle exec rails server puma

