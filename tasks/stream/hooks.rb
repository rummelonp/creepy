# -*- coding: utf-8 -*-

class Creepy::Stream
  module Hooks
    class << self
      def hooks
        @_hooks ||= {}
      end

      def add_hook(name, hook)
        hooks[name] = hook
      end
    end

    Dir[File.dirname(__FILE__) + '/hooks/*.rb'].each {|f| require f}
  end
end
