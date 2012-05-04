# -*- coding: utf-8 -*-

module Creepy
  module Tasks
    class Cli < Base
      def setup
        task_name  = ARGV.delete_at(0).to_s.downcase.to_sym if ARGV[0].present?
        task = Creepy::Tasks.mappings[task_name]

        if task
          task.start ARGV
        else
          self.class.help(shell)
        end
      end

      class << self
        def banner
          "#{basename} [task]"
        end

        def desc
          description = "Tasks:\n"
          Creepy::Tasks.mappings.map do |k, v|
            description << "  #{basename} #{k.to_s.ljust(10)} # #{v.desc}\n"
          end

          description
        end
      end
    end
  end
end
