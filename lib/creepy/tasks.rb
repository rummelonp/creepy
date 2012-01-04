# -*- coding: utf-8 -*-

module Creepy
  module Tasks
    class << self
      def tasks
        @_tasks ||= {}
      end

      def add_task(name, task)
        tasks[name] = task
      end
    end

    Dir[Dir.pwd + '/tasks/*.rb'].each {|f| require f}
  end
end
