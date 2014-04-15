# Dockerfile for installation of huginn (https://github.com/cantino/huginn)
#
# VERSION 1.0.0

FROM ubuntu:12.04

MAINTAINER Jamie Atkinson "jabbslad@gmail.com"

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

ENV HOME /root
ENV RBENV_ROOT $HOME/.rbenv
ENV RUBY_VERSION 1.9.3-p545
ENV RUBYGEMS_VERSION 2.2.2

# manually setup environment
ENV PATH $HOME/.rbenv/shims:$HOME/.rbenv/bin:$RBENV_ROOT/versions/$RUBY_VERSION/bin:$PATH

RUN apt-get install -y build-essential curl zlib1g-dev libreadline-dev libssl-dev libcurl4-openssl-dev git libmysqlclient-dev mysql-server

RUN git clone https://github.com/sstephenson/rbenv.git $HOME/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git $HOME/.rbenv/plugins/ruby-build

# install & set global ruby version
RUN rbenv install $RUBY_VERSION
RUN rbenv global $RUBY_VERSION

WORKDIR /usr/local/src

RUN curl -O http://production.cf.rubygems.org/rubygems/rubygems-$RUBYGEMS_VERSION.tgz
RUN tar -xvf rubygems-$RUBYGEMS_VERSION.tgz
RUN cd rubygems-$RUBYGEMS_VERSION ; ruby setup.rb

RUN gem install bundle

RUN git clone git://github.com/cantino/huginn.git

WORKDIR huginn

# install app dependencies
RUN bundle

RUN sed 's/REPLACE_ME_NOW!/'$(rake secret)'/' .env.example > .env

# Setup database
RUN (mysqld_safe --user=mysql &) ; rake db:create ; rake db:migrate ; rake db:seed

EXPOSE 3000

CMD ((mysqld_safe --user=mysql &) ; foreman start)

