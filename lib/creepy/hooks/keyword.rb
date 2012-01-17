# -*- coding: utf-8 -*-

module Creepy
  module Hooks
    class Keyword
      attr_accessor :include, :exclude, :hooks, :formatter, :notifies

      def initialize(options = {}, &block)
        @include   = options.fetch :include,   []
        @exclude   = options.fetch :exclude,   []
        @hooks     = options.fetch :hooks,     []
        @formatter = options.fetch :formatter, Formatter.default
        @notifies  = options.fetch :notifies,  []
        yield self if block_given?
      end

      def call(status)
        return unless status.text
        return unless @include.flatten.any? {|k| status.text.match(k)}
        keyword = $&.to_s
        return if @exclude.flatten.any? {|k| status.text.match(k)}
        @hooks.each {|h| h.call(keyword, status)}
        title, message = @formatter.call(keyword, status)
        @notifies.each {|n| n.call(title, message)}
      end

      module Formatter
        extend self

        def default
          lambda do |keyword, status|
            ["@#{status.user.screen_name} \"#{keyword}\"",
             "#{status.text} from #{status.source.gsub(/<\/?[^>]*>/, '')}"]
          end
        end

        def simple
          lambda do |keyword, status|
            ["@#{status.user.screen_name} \"#{keyword}\"",
             status.text.truncate(40)]
          end
        end
      end
    end
  end
end
