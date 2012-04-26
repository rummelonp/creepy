# -*- coding: utf-8 -*-

require 'thor/group'

module Creepy
  module Tasks
    class Console < Thor::Group
      Tasks.add_task :console, self

      def console
        Pry.start
      end
    end
  end
end
