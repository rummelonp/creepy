# -*- coding: utf-8 -*-

module Creepy
  module Hooks
    class Event
      attr_accessor :adapter

      def self.with_adapter(&block)
        new(Adapter.new(&block))
      end

      def initialize(adapter = nil)
        @adapter = adapter
      end

      def call(status)
        return unless status.event
        return unless @adapter
        return if status.source.screen_name == credentials.screen_name
        @adapter.call(status.event, status)
      end

      private
      def credentials
        Creepy.config.twitter.credentials
      end

      class Adapter
        attr_accessor :handlers, :notifies

        def initialize(options = {}, &block)
          @handlers = options.fetch :handlers, {}
          @notifies = options.fetch :notifies, []
          yield self if block_given?
        end

        def handler(event)
          @handlers[event] ||= []
        end

        def on(event, &block)
          event = event.to_sym
          handler(event) << block
          self
        end

        def notify(event, &block)
          on(event) do |status|
            title, message = block.call(status)
            @notifies.each {|n| n.call(title, message)}
          end
        end

        def call(event, status)
          event = event.to_sym
          handler(event).each {|h| h.call(status)}
        end
      end
    end
  end
end
