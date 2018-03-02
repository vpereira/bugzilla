FROM ubuntu:xenial

RUN apt-get -qq update
RUN apt-get install -y libxml2-dev libmagickcore-dev ruby ruby-dev libmagickwand-dev
RUN gem install bundler
