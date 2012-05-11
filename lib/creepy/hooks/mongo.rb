# -*- coding: utf-8 -*-

module Creepy
  register_default do |config|
    config.mongo do |mongo|
      mongo.set_default :host,      'localhost'
      mongo.set_default :port,      27017
      mongo.set_default :db_name,   'creepy'
      mongo.set_default :connection, nil
      mongo.set_default :db,         nil
    end
  end

  module Hooks
    module Mongo
      extend self

      def new(db)
        lambda do |status|
          db.collection(key_from_status(status)).insert(status)
        end
      end

      def with_mecab(db)
        require 'natto'
        nm = Natto::MeCab.new('-O wakati')
        lambda do |status|
          if status.text
            status.keywords = nm.parse(status.text).split(' ')
          end
          db.collection(key_from_status(status)).insert(status)
        end
      end

      private
      def key_from_status(status)
        key = %w{friends event delete}.find {|key| status.key? key} || 'status'
      end
    end
  end

  def connection
    mongo = config.mongo
    mongo.connection ||= ::Mongo::Connection.new(mongo.host, mongo.port)
  end

  def db
    mongo = config.mongo
    mongo.db ||= connection.db(mongo.db_name)
  end
end
