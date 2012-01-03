# -*- coding: utf-8 -*-

module Creepy
  module Configuration
    def config
      @config ||= load_config
    end

    def configure
      yield config
      self
    end

    def reload_config!
      config.merge!(load_config)
    end

    private
    def load_config
      Hashie::Mash.new(YAML.load_file('config/config.yml'))
    rescue
      Hashie::Mash.new
    end
  end
end
