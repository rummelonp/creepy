# -*- coding: utf-8 -*-

module Creepy
  class Stream < Task
    Tasks.add_task :stream, self

    class_option :daemon, aliases: '-d', default: false, type: :boolean

    def setup
      Creepy.reload_config!

      @client = UserStream.client(Creepy.config)

      @hooks = []
      Creepy.config('stream.hooks', {}).each do |hook_name, params|
        hook = Hooks.hooks[hook_name.to_sym]
        @hooks << hook.new(params || {}) if hook
      end
    rescue
      shell.error "#{$!.class}: #{$!.message}"
      raise SystemExit
    end
    alias_method :reload, :setup

    def trap
      Signal.trap(:HUP) do
        reload
      end
    end

    def boot
      Process.daemon if options.daemon?
      loop do
        process
      end
    end

    private
    def process
      @client.user do |status|
        @hooks.each {|h| h.call status}
      end
    rescue
      shell.error "#{$!.class}: #{$!.message}"
    end

    Dir[File.dirname(__FILE__) + '/stream/*.rb'].each {|f| require f}
  end
end
