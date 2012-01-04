# -*- coding: utf-8 -*-

require 'thor/group'

class Creepy::Tasks
  class Task < Thor::Group
    include Thor::Actions
    include Creepy::Actions
  end
end
