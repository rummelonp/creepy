# -*- coding: utf-8 -*-

require 'thor/group'

module Creepy
  module Tasks
    class Base < Thor::Group
      class << self
        def banner
          "#{basename} #{name.split('::').last.downcase}"
        end
      end
    end
  end
end
