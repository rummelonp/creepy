# -*- coding: utf-8 -*-

module Creepy
  module Helper
    def root
      File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
    end

    def log_dir
      File.join(Creepy.root, 'log')
    end

    def logger
      config.logger
    end

    def connection
      mongo = config.mongo
      mongo.connection ||= Mongo::Connection.new(mongo.host, mongo.port)
    end

    def db
      mongo = config.mongo
      mongo.db ||= connection.db(mongo.db_name)
    end

    def twitter(options = {})
      Twitter.new(config.twitter.to_hash.merge(options))
    end
    alias_method :client, :twitter

    def user_stream(options = {})
      UserStream.client(config.twitter.to_hash.merge(options))
    end
    alias_method :stream, :user_stream
  end

  extend Helper
end
