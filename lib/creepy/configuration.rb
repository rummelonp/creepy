# -*- coding: utf-8 -*-

module Creepy
  module Configuration
    def config(keys = nil, default_value = nil)
      @config ||= load_config
      if keys && keys.is_a?(String) && keys.present?
        keys = keys.split('.')
        value = @config
        while !keys.empty? && value
          value = value[keys.shift]
        end
        value || default_value
      else
        @config
      end
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
