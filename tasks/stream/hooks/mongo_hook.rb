# -*- coding: utf-8 -*-

class Creepy::Tasks::Stream::Hooks
  class MongoHook
    Creepy::Tasks::Stream::Hooks.add :mongo, self

    def initialize(options = {})
      @db = Creepy::Database.db(options)
    end

    def call(status)
      key = %w{friends event delete}.find {|key| status.key? key} || 'status'
      @db.collection(key).insert(status)
    end
  end
end
