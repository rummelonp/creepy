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

      attr_reader :logger

      private
      def tee(level, message)
        if [:error, :warn, :fatal].include?(level)
          shell.error message
        else
          shell.say message
        end
        logger.send level, message if logger
      end
    end
  end
end
