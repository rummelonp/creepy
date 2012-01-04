# -*- coding: utf-8 -*-
require 'MeCab'

class Creepy::Tasks::Stream::Hooks
  class MongoHook
    Creepy::Tasks::Stream::Hooks.add :mongo, self

    def initialize(options = {})
      @db = Creepy::Database.db(options)
    end

    def call(key, status)
      if status['text']
        m = ::MeCab::Tagger.new("-Owakati")
        status['keywords'] = m.parse(status['text']).split(' ').map { |w| w.force_encoding("utf-8") }
      end
      @db.collection(key).insert(status)
    end
  end
end
