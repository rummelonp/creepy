# -*- coding: utf-8 -*-

require 'thor/group'

module Creepy
  module Tasks
    class Stream < Thor::Group
      Tasks.add_task :stream, self

      extend Creepy::Configuration

      Creepy.config.twitter do |twitter|
        twitter.credentials = nil
      end

      configure do |stream|
        stream.set_default :params, {}
        stream.set_default :hooks,  []
      end

      def setup
        config  = Creepy.config
        twitter = config.twitter
        @client = Twitter.new(twitter)
        @stream = UserStream.client(twitter)
        @logger = config.logger
        @hooks  = self.class.config.hooks  || []
        @params = self.class.config.params || {}
        twitter.credentials ||= @client.verify_credentials
        tee :info, "Stream#setup: read config"
      rescue
        tee :warn, "Stream#setup: #{$!.message} (#{$!.class})"
        raise SystemExit
      end

      def trap
        Signal.trap :HUP do
          Creepy.reload_config!
          setup
        end
      end

      def boot
        loop do
          tee :info, 'Stream#boot: start receive stream'
          request
        end
      end

      private
      def request
        @stream.user @params, &method(:read)
      rescue
        tee :error, "Stream#request: #{$!.message} (#{$!.class})"
      end

      def read(status)
        tee :debug, "Stream#read: receive body"
        @hooks.each {|h| h.call(status)}
      rescue
        tee :error, "Stream#read: #{$!.message} (#{$!.class})"
      end

      def tee(level, message)
        if [:error, :warn, :fatal].include?(level)
          shell.error message
        else
          shell.say message
        end
        @logger.send level, message unless @logger.nil?
      end
    end
  end
end
