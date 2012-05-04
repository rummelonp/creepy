# -*- coding: utf-8 -*-

module Creepy
  module Tasks
    class << self
      def mappings
        @mappings ||= ActiveSupport::OrderedHash.new
      end

      def add_task(name, klass)
        mappings[name] = klass
      end
    end
  end
end

require 'creepy/tasks/base'
require 'creepy/tasks/cli'
Dir[File.dirname(__FILE__) + '/tasks/*.rb'].each {|f| require f}
