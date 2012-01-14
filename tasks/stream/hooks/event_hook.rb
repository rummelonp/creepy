# -*- coding: utf-8 -*-

class Creepy::Tasks::Stream::Hooks
  class EventHook
    Creepy::Tasks::Stream::Hooks.add :event, self

    def initialize(options = {})
      options = Creepy.config('notifies', {}).merge(options)
      @notifies = Creepy::Notifies.new(options)
    end

    def self?
      (@credentials ||= Twitter.verify_credentials).screen_name == @status.source.screen_name
    end

    def notify(title, body)
      @notifies.notify(title, body) unless self?
    end

    def call(key, status)
      key = status.event if key == "event"
      @status = status

      case key
      when 'favorite'
        notify("☆#{status.source.screen_name}", status.target_object.text)
      when 'unfavorite'
        notify("!!unfav!! #{status.source.screen_name}", status.target_object.text)
      when 'follow'
        notify("!!follow!! @#{status.source.screen_name}", nil)
      end
    end
  end
end
