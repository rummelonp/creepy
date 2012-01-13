# -*- coding: utf-8 -*-

require 'thor/group'

module Creepy
  module Tasks
    class Cli < Thor::Group
      def setup
        task_name  = ARGV.delete_at(0).to_s.downcase.to_sym if ARGV[0].present?
        task = Creepy::Tasks.mappings[task_name]

        if task
          task.start ARGV
        else
          puts "Please specify task to use (#{Creepy::Tasks.mappings.keys.join(", ")})"
        end
      end
    end
  end
end
