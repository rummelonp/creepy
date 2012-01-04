# -*- coding: utf-8 -*-

module Creepy
  module Database
    class << self
      def connection(options = {})
        options = Creepy.config('database', {}).merge(options)
        Mongo::Connection.new(options[:host], options[:port])
      end

      def db(options = {})
        options = Creepy.config('database', {}).merge(options)
        name = options.delete(:name)
        connection(options).db(name)
      end
    end
  end
end
