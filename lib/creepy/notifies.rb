# -*- coding: utf-8 -*-

module Creepy
  class Notifies < Mapper
    Dir[File.dirname(__FILE__) + '/notifies/*.rb'].each {|f| require f}

    def initialize(options = {})
      options.each do |name, params|
        notify = self.class.mappings[name.to_sym]
        notifies << notify.new(params || {}) if notify
      end
    end

    def notifies
      @notifies ||= []
    end

    include Enumerable

    def each
      notifies.each do |notify|
        yield notify
      end
    end

    def notify(title, message, options = {})
      notifies.each {|n| n.notify(title, message, options)}
    end
  end
end
