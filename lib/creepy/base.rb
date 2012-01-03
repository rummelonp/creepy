# -*- coding: utf-8 -*-

require 'thor/group'

module Creepy
  class Base < Thor::Group
    include Thor::Actions
    include Creepy::Actions
  end
end
