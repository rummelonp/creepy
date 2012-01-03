# -*- coding: utf-8 -*-

class Creepy::Stream
  class MongoHook
    Hooks.add_hook :mongo, self

    def initialize(options = {})
      db_name = options[:db_name] || 'creepy'
      @db = Mongo::Connection.new.db(db_name)
    end

    def call(status)
      key = %w{friends event delete}.find {|key| status.key? key} || 'status'
      @db.collection(key).insert(status)
    end
  end
end
