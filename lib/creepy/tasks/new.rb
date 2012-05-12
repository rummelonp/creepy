# -*- coding: utf-8 -*-

module Creepy
  module Tasks
    class New < Base
      Tasks.add_task :new, self

      include Thor::Actions

      desc 'Create new task'

      def self.banner
        "#{super} [task_name]"
      end

      argument :task_name

      def create
        task_path = File.join(Creepy.root, 'tasks', "#{task_name}.rb")
        create_file(task_path) do
          template = open(__FILE__).readlines
            .grep(/^##/)
            .map {|l| l.gsub(/^##/, '')}
            .join('')
          template % {
            :task_class_name => task_name.camelize,
            :task_name       => task_name
          }
        end
      end
    end
  end
end

## # -*- coding: utf-8 -*-
##
## module Creepy
##   module Tasks
##     class %{task_class_name} < Base
##       Tasks.add_task :%{task_name}, self
##
##       def setup
##       end
##
##       def %{task_name}
##       end
##
##       def teardown
##       end
##     end
##   end
## end
