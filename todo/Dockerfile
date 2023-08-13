FROM ruby:3.2.2
RUN apt-get install libpq-dev

RUN mkdir /app
WORKDIR   /app

ENV BUNDLE_PATH /tmp/bundle
ENV GEM_PATH /tmp/bundle
ENV GEM_HOME /tmp/bundle

RUN gem install bundle
COPY ./Gemfile /app

RUN bundle install
COPY . /app
RUN chmod +x ./run

EXPOSE 3002

CMD ./run