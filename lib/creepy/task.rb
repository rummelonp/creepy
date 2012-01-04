# -*- coding: utf-8 -*-

require 'thor/group'

module Creepy
  class Task < Thor::Group
    include Thor::Actions
    include Creepy::Actions
  end
end
