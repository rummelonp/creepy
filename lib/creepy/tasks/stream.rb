# -*- coding: utf-8 -*-

module Creepy
  module Tasks
    class Stream < Base
      Tasks.add_task :stream, self

      desc 'Starts up creepy stream'

      extend Creepy::Configuration

      register_default do |stream|
        stream.set_default :params, {}
        stream.set_default :hooks,  []
      end

      def setup
        config  = Creepy.config
        @client = Creepy.client
        @stream = Creepy.stream
        @hooks  = self.class.config.hooks  || []
        @params = self.class.config.params || {}
        @logger = config.logger
        @credentials = @client.verify_credentials
        @hooks.each do |h|
          h.credentials = @credentials if h.respond_to? :credentials=
        end
        tee :info, "Stream#setup: read config"
      rescue
        tee :warn, "Stream#setup: #{$!.message} (#{$!.class})"
        raise SystemExit
      end

      def trap
        Signal.trap :HUP do
          begin
            Creepy.reload_config!
            setup
          rescue Error
            tee :error, "Stream#trap: #{$!.message} (#{$!.class})"
          end
        end
        Signal.trap :TERM do
          tee :info, 'Stream#trap: terminated'
          raise SystemExit
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
    end
  end
end
