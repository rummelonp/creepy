# -*- coding: utf-8 -*-

module Creepy
  module Tasks
    class Console < Base
      Tasks.add_task :console, self

      desc 'Boots up the creepy pry console'

      def console
        Pry.start
      end
    end
  end
end
