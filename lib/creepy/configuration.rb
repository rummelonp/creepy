# -*- coding: utf-8 -*-

class Module
  def to_configatron(*args)
    self.name.to_configatron(*args)
  end
end

module Creepy
  module Configuration
    def config(*args)
      to_configatron(*args)
    end

    def configure
      yield config
      self
    end
  end

  extend Configuration
end
