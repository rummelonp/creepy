# -*- coding: utf-8 -*-

module Creepy
  class Loggers < Mapper
    def initialize(options = {})
      options.each do |name, params|
        logger = self.class.mappings[name.to_sym]
        loggers << logger.new(params || {}) if logger
      end
    end

    def loggers
      @loggers ||= []
    end

    include Enumerable

    def each
      loggers.each do |logger|
        yield logger
      end
    end

    def method_missing(method_name, *args, &block)
      return super unless respond_to?(method_name)
      each do |l|
        next unless l.respond_to?(method_name)
        l.send(method_name, *args, &block)
      end
    end

    def respond_to?(method_name)
      any? {|l| l.respond_to?(method_name)} || super
    end

    Dir[File.dirname(__FILE__) + '/loggers/*.rb'].each {|f| require f}
  end
end
