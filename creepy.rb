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

    class_option :help, :alias => '-h', :type => :boolean, :desc => "ヘルプを表示"

    desc 'friends [USER]', 'ユーザのフレンドを取得'
    method_option :diff, :alias => '-d', :type => :boolean, :default => false, :desc => 'データを取得後に差分を計算する'
    def friends(*args)
      prepare :friends, args.size == 1
      user = args.shift

      description = "#{user} のフレンド"
      users = process(:friends, description, user)
      create_file "data/#{user}_friends_#{time}.yml", YAML.dump(users)
      say "#{description}を取得しました"

      if options.diff?
        diff :friends, user
      end
    rescue
      error! $!.message
    end

    desc 'list [USER] [LIST_NAME]', 'リストに登録されているメンバーを取得'
    method_option :diff, :alias => '-d', :type => :boolean, :default => false, :desc => 'データを取得後に差分を計算する'
    def list(*args)
      prepare :list, args.size == 2
      user, list_name = *args

      description = "list #{user}/#{list_name} に登録されているメンバー"
      users = process(:list_members, description, user, list_name)
      create_file "data/#{user}_#{list_name}_#{time}.yml", YAML.dump(users)
      say "#{description}を取得しました"

      if options.diff?
        diff :list, user, list_name
      end
    rescue
      error! $!.message
    end

    desc 'diff [TASK] [NAME], ...', '最新のデータと以前のデータの差分を計算'
    def diff(*args)
      prepare :diff, args.size >= 1
      case args.shift.to_sym
      when :friends
        error! '[USER] を指定してください' unless args.size == 1
        user = args.shift
        file_prefix = "#{user}_friends"
        description = "#{user} のフレンド"
      when :list
        error! '[USER] [LIST_NAME] を指定してください' unless args.size == 2
        user, list_name = *args
        file_prefix = "#{user}_#{list_name}"
        description = "list #{user}/#{list_name} に登録されているメンバー"
      else
        error! '[TASK] には "friends" または "list" を指定してください'
      end

      files = Dir.glob("data/#{file_prefix}*")
      error! "#{description}のデータが見つかりません" unless files.size >= 2

      dest_path, source_path = *files.reverse
      say "#{description} #{dest_path} と #{source_path} の差分を計算中..."

      dest_time = dest_path.match(/\d+/).to_s
      source_time = source_path.match(/\d+/).to_s
      log_path = "log/#{file_prefix}_#{dest_time}_#{source_time}.log"
      create_file log_path

      dest   = YAML.load_file dest_path
      source = YAML.load_file source_path

      # id を key にして詰め替え
      dest, source = [dest, source].map do |u|
        {}.tap {|h| u.each {|v| h[v[:id]] = v } }
      end

      # 新しいフォロー
      dest.select {|id, u| !source.has_key? id }.each do |id, user|
        tee "フォロー > @#{user[:screen_name]}", log_path
      end

      # アンフォロー または アカウント削除
      source.select {|id, u| !dest.has_key? id }.each do |id, user|
        begin
          rubytter.user id
          tee "アンフォロー > @#{user[:screen_name]}", log_path
        rescue
          tee "#{$!.message} > @#{user[:screen_name]}", log_path
        end
      end

      # プロフィールの差分取得
      dest.each do |id, dest_user|
        next unless source.has_key? id

        source_user = source[id]

        [
         {:key => :screen_name,       :name => 'スクリーンネーム'},
         {:key => :name,              :name => '名前'},
         {:key => :description,       :name => 'プロフィール'},
         {:key => :location,          :name => '場所'},
         {:key => :url,               :name => 'URL'},
         {:key => :protected,         :name => '鍵'},
         {:key => :profile_image_url, :name => 'アイコン'}
        ].each do |data|
          dest_data   = dest_user.send(:[], data[:key])
          source_data = source_user.send(:[], data[:key])
          if source_data && dest_data != source_data
            tee "@#{dest_user[:screen_name]} #{data[:name]} > \"#{source_data}\" -> \"#{dest_data}\"", log_path
          end
        end
      end
    end

    desc 'help [TASK]', 'ヘルプを表示'
    def help(*args)
      super
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

    def prepare(task, cond = true)
      if options.help? || !cond
        help task
        raise SystemExit
      end
    end

    def error!(*args)
      shell.error *args
      raise SystemExit
    end

    def tee(dest, path)
      say dest
      open(path, 'a') {|f| f.puts dest }
    rescue
      shell.error $!.message
    end
  end
end

Creepy::Cli.start
