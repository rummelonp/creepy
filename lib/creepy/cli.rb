# -*- coding: utf-8 -*-

require 'thor/group'

module Creepy
  class Cli < Thor::Group
    def setup
      task_name = ARGV.delete_at(0).to_s.downcase.to_sym if ARGV[0].present?
      task = Tasks.tasks[task_name]

      if task
        args = ARGV.empty? && task.require_arguments? ? ['-h'] : ARGV
        task.start args
      else
        puts "Please specify task (#{Tasks.tasks.keys.join(', ')})"
      end
    end
  end
end
