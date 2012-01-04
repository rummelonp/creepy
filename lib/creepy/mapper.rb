# -*- coding: utf-8 -*-

module Creepy
  class Mapper
    class << self
      def mappings
        @mappings ||= ActiveSupport::OrderedHash.new
      end

      def add(name, data)
        mappings[name] = data
      end
    end
  end
end
