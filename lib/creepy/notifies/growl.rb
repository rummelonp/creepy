# -*- coding: utf-8 -*-

require 'digest/sha1'

class Creepy::Notifies
  class Growl
    Creepy::Notifies.add :growl, self

    def initialize(options = {})
      options = Creepy.config('notifies.growl', {}).merge(options)
      env = options[:env]
      if env
        ENV['NOTIFY'] = env
        require 'notify'
      end
    end

    def notify(title, message, options = {})
      Notify.notify(title, message, options)
    end
  end
end
