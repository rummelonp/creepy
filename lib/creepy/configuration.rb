# -*- coding: utf-8 -*-

class Module
  def to_configatron(*args)
    self.name.to_configatron(*args)
  end
end

module Creepy
  extend self

  def root
    File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  end

  def reload_config!
    config_path = File.join(root, 'config', 'config.rb')
    load config_path
  end

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
