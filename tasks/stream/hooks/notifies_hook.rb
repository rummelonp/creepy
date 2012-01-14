# -*- coding: utf-8 -*-

class Creepy::Tasks::Stream::Hooks
  class NotifiesHook
    Creepy::Tasks::Stream::Hooks.add :notifies, self

    def initialize(options = {})
      options = Creepy.config('notifies', {}).merge(options)
      @notifies = Creepy::Notifies.new(options)
      @regexp = Creepy.config('ego', {}).merge(options)
    end

    def call(key, status)
      key = status.event if key == "event"

      case key
      when 'favorite'
        @notifies.notify("☆#{status.source.screen_name}",status.target_object.text)
      when 'unfavorite'
        @notifies.notify("!!unfav!! {status.source.screen_name}",status.target_object.text)
      when 'follow'
        @notifies.notify("!!follow!! @#{status.source.screen_name}", nil)
      else
        if status.text ? status.text.match(/#{@regexp.regexp}/) : false
          @notifies.notify(status.user.screen_name,"match:#{$1},text:#{status.text},via:#{status.source}")
        end
      end
    end
  end
end
