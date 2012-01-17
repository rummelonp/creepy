# -*- coding: utf-8 -*-

require 'yaml'

Creepy.configure do |config|
  current = File.dirname(__FILE__)
  root = File.join(current, '..')

  ## アカウント情報等の読み込み
  accounts_file = File.join(current, 'accounts.yml')
  accounts = Hashie::Mash.new(YAML.load_file(accounts_file))

  ## Logger の設定
  log_dir = File.join(root, 'log')
  log_file = File.join(log_dir, 'creepy.log')
  config.logger = Logger.new(log_file)
  config.logger.progname = Creepy
  config.logger.level = Logger::DEBUG
  config.logger.formatter = Logger::Formatter.new

  ## Twitter アカウントの設定
  config.twitter do |twitter|
    twitter.consumer_key       = accounts.twitter.consumer_key
    twitter.consumer_secret    = accounts.twitter.consumer_secret
    twitter.oauth_token        = accounts.twitter.oauth_token
    twitter.oauth_token_secret = accounts.twitter.oauth_token_secret
  end

  ## Mongo の設定
  config.mongo do |mongo|
    mongo.host       = 'localhost'
    mongo.port       = 27017
    mongo.db_name    = 'creepy'
    mongo.connection = Mongo::Connection.new(mongo.host, mongo.port)
    mongo.db         = mongo.connection.db(mongo.db_name)
  end

  ## 通知の設定
  config.notifies do |notifies|
    ## im.kayac.com アカウントの設定
    notifies.im_kayac_com do |im_kayac_com|
      im_kayac_com.username = accounts.im_kayac_com.username
      im_kayac_com.password = accounts.im_kayac_com.password
      im_kayac_com.sig_key  = accounts.im_kayac_com.sig_key
    end
  end

  ## タスクの設定
  config.tasks do |tasks|
    ## Stream タスクの設定
    tasks.stream do |stream|
      ## stream.hooks に利用する hook を追加
      ## status を受け取る call メソッドを実装したオブジェクト

      ## デバッグ用
      # stream.hooks << lambda {|status| puts status}

      ## Mongo Hook 追加
      ## 全ての status を種類ごとに collection に分け保存
      # stream.hooks << Creepy::Hooks::Mongo.new(config.mongo.db)
      ## status.text の MeCab による分かち書きを status.keywords として保存
      stream.hooks << Creepy::Hooks::Mongo.with_mecab(config.mongo.db)

      ## Keyword Hook 追加
      keyword = Creepy::Hooks::Keyword.new

      ## キーワード設定
      keyword.include << 'twitter'
      keyword.exclude << /^.*(RT|QT):? @[\w]+.*$/i

      ## マッチした keyword と status を受け取る hook の設定
      # keyword.hooks << lambda {|keyword, status| puts keyword, status}
      keyword.hooks << lambda do |keyword, status|
        status.keyword = keyword
        config.mongo.db.collection('keyword').insert(status)
      end

      ## 通知のフォーマット設定
      ## keyword, status を受け取り [title, message] を返す call メソッドを実装したオブジェクト
      ## 標準は Creepy::Hooks::Keyword::Formatter.default
      # keyword.formatter = Creepy::Hooks::Keyword::Formatter.simple

      ## 通知先の設定
      ## title, message を受け取る call メソッドを実装したオブジェクト
      # keyword.notifies << lambda {|title, message| puts title, message}
      keyword.notifies << Creepy::Notifies::ImKayacCom.new

      stream.hooks << keyword
    end
  end
end