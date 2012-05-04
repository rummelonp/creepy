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

  def defaults
    @defaults ||= []
  end

  def reload_config!
    configatron.reset!
    defaults.each {|d| d.call}
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

    def register_default(&block)
      default = lambda do
        configure &block
      end
      Creepy.defaults << default
      default.call
      self
    end
  end

  extend Configuration
end
