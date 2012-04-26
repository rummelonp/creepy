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
        return unless @adapter
        if status.event
          return if yourself? status.source.screen_name
          event = status.event.to_sym
        elsif status.direct_message
          return if yourself? status.direct_message.sender_screen_name
          event = :direct_message
        elsif status.retweeted_status
          return unless yourself? status.retweeted_status.user.screen_name
          event = :retweet
        elsif yourself? status.in_reply_to_screen_name
          event = :reply
        else
          return
        end
        @adapter.call(event, status)
      end

      private
      def yourself?(screen_name)
        credentials.screen_name == screen_name
      end

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
          if block.nil? && Formatter.respond_to?(event)
            block = Formatter.send(event)
          end
          on(event) do |status|
            title, message, options = block.call(status)
            @notifies.each {|n| n.call(title, message, options)}
          end
        end

        def call(event, status)
          handler(event).each {|h| h.call(status)}
        end
      end

      module Formatter
        extend self

        def reply
          lambda do |status|
            ["@#{status.user.screen_name} Mentioned",
             "#{status.text}",
             {}]
          end
        end

        def retweet
          lambda do |status|
            ["@#{status.user.screen_name} Retweeted",
             "#{status.retweeted_status.text}",
             {}]
          end
        end

        def direct_message
          lambda do |status|
            ["@#{status.direct_message.sender.screen_name} Sent message",
             "#{status.direct_message.text}",
             {}]
          end
        end

        def favorite
          lambda do |status|
            ["@#{status.source.screen_name} Favorited",
             status.target_object.text,
             {}]
          end
        end

        def unfavorite
          lambda do |status|
            ["@#{status.source.screen_name} Unfavorited",
             status.target_object.text,
             {}]
          end
        end

        def follow
          lambda do |status|
            ["@#{status.source.screen_name} Followed",
             "@#{status.target.screen_name}",
             {}]
          end
        end

        def list_member_added
          lambda do |status|
            ["@#{status.source.screen_name} Added to list",
             "#{status.target_object.full_name}",
             {}]
          end
        end

        def list_member_removed
          lambda do |status|
            ["@#{status.source.screen_name} Removed from list",
             "#{status.target_object.full_name}",
             {}]
          end
        end

        def list_user_subscribed
          lambda do |status|
            ["@#{status.source.screen_name} Subscribed list",
             "#{status.target_object.full_name}",
             {}]
          end
        end

        def list_user_unsubscribed
          lambda do |status|
            ["@#{status.source.screen_name} Unsubscribed list",
             "#{status.target_object.full_name}",
             {}]
          end
        end
      end
    end
  end
end
