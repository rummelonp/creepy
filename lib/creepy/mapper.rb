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

      include Enumerable

      def each
        mappings.each do |data|
          yield data
        end
      end
    end
  end
end
