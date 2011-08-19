# -*- coding: utf-8 -*-

module Creepy
  class ConfigLoader
    def self.load
      begin
        Hashie::Mash.new(YAML.load_file('config/config.yml'))
      rescue
        Hashie::Mash.new
      end
    end
  end
end
