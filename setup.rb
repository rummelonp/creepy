#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'bundler'
Bundler.require
require 'thor/group'
require 'yaml'

class Setup < Thor::Group
  include Thor::Actions

  desc 'Creepy のセットアップ'

  def setup
    begin
      config = YAML.load_file 'config.yml'
    rescue
      config = {}
    end

    app = {}
    app[:consumer_key]    = ask 'Consumer Key を入力してください:'
    app[:consumer_secret] = ask 'Consumer Secret を入力してください:'

    consumer = OAuth::Consumer.new(
      app[:consumer_key],
      app[:consumer_secret],
      {:site => 'http://api.twitter.com'}
    )

    request_token = consumer.get_request_token
    unless system 'open', request_token.authorize_url
      say '================================================================='
      say request_token.authorize_url
      say '================================================================='
      say '上記URLからアプリを認証し '
    end
    pin = ask 'PIN を入力してください:'

    access_token = request_token.get_access_token(
      :oauth_token    => request_token.token,
      :oauth_verifier => pin
    )

    app[:access_token]        = access_token.token
    app[:access_token_secret] = access_token.secret

    config[:app] = app

    create_file 'config.yml', YAML.dump(config)
    chmod 'config.yml', 0600
    say 'Creepy のセットアップが完了しました'
  end
end

Setup.start
