# -*- coding: utf-8 -*-

class Creepy::Tasks::Stream::Hooks
  class KeywordHook
    Creepy::Tasks::Stream::Hooks.add :keyword, self

    def initialize(options = {})
      @ego = Creepy.config('ego', {})
      options = Creepy.config('notifies', {}).merge(options)
      @notifies = Creepy::Notifies.new(options)
    end

    def call(key, status)
      if status.text ? status.text.match(/#{@ego.regexp}/i) : false
        @notifies.notify(status.user.screen_name,"match:#{$1},text:#{status.text},via:#{status.source}")
      end
    end
  end
end
