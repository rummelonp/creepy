# -*- coding: utf-8 -*-

module Creepy
  module Hooks
    class User
      attr_accessor :include, :hooks, :formatter, :notifies

      def initialize(options = {}, &block)
        @include     = options.fetch :include,     []
        @hooks       = options.fetch :hooks,       []
        @formatter   = options.fetch :formatter,   Formatter.default
        @notifies    = options.fetch :notifies,    []
        yield self if block_given?
      end

      def call(status)
        return unless status.text
        return unless @include.flatten.any? {|u| status.user.screen_name == u}
        screen_name = status.user.screen_name
        @hooks.each {|h| h.call(screen_name, status)}
        title, message, options = @formatter.call(screen_name, status)
        @notifies.each {|n| n.call(title, message, options)}
      end

      module Formatter
        extend self

        def default
          lambda do |screen_name, status|
            ["@#{screen_name} Say",
             "#{status.text} from #{status.source.gsub(/<\/?[^>]*>/, '')}",
             {}]
          end
        end

        def simple
          lambda do |screen_name, status|
            ["@#{screen_name} Say",
             status.text.truncate(40),
             {}]
          end
        end
      end
    end
  end
end
