# -*- coding: utf-8 -*-

class Creepy::Tasks::Stream
  class Hooks < Creepy::Mapper
    Dir[File.dirname(__FILE__) + '/hooks/*.rb'].each {|f| require f}

    def initialize(options = {})
      options.each do |name, params|
        hook = self.class.mappings[name.to_sym]
        hooks << hook.new(params || {}) if hook
      end
    end

    def hooks
      @hooks ||= []
    end

    def call(status)
      hooks.each {|h| h.call(status)}
    end
  end
end
