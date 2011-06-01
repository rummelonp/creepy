#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'bundler'
Bundler.require
require 'yaml'

module Creepy
  def config
    begin
      @config ||= YAML.load_file('config.yml')
    rescue
      raise SystemExit
    end
  end

  def rubytter
    return @rubytter if @rubytter

    app = config[:app]

    consumer = OAuth::Consumer.new(
      app[:consumer_key],
      app[:consumer_secret],
      {:site => 'http://api.twitter.com'}
    )

    access_token = OAuth::AccessToken.new(
      consumer,
      app[:access_token],
      app[:access_token_secret]
    )

    @rubytter = OAuthRubytter.new(access_token)
  end

  def time
    Time.now.strftime('%Y%m%d%H%M')
  end

  class Cli < Thor
    include Creepy
    include Thor::Actions

    desc 'friends [USER]', 'ユーザのフレンドを取得'
    def friends(user)
      description = "#{user} のフレンド"
      users = process(:friends, description, user)
      create_file "data/#{user}_friends_#{time}.yml", YAML.dump(users)
      say "#{description}を取得しました"
    rescue
      shell.error $!.message
    end

    desc 'list [USER] [LIST_NAME]', 'リストに登録されているメンバーを取得'
    def list(user, list_name)
      description = "list #{user}/#{list_name} に登録されているメンバー"
      users = process(:list_members, description, user, list_name)
      create_file "data/#{user}_#{list_name}_#{time}.yml", YAML.dump(users)
      say "#{description}を取得しました"
    rescue
      shell.error $!.message
    end

    private
    def process(method, description, *args)
      users, next_cursor, index = [], -1, 1
      while next_cursor != 0
        say "#{description} #{index} ページ目を取得しています..."
        result = rubytter.send(method, *(args.dup << {:cursor => next_cursor}))
        users.concat result.users
        next_cursor = result.next_cursor
        index += 1
      end
      users
    end
  end
end

Creepy::Cli.start
