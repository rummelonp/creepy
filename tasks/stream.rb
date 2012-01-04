# -*- coding: utf-8 -*-

class Creepy::Tasks
  class Stream < Task
    Creepy::Tasks.add :stream, self

    class_option :daemon, aliases: '-d', default: false, type: :boolean

    def setup
      Creepy.reload_config!
      @client = UserStream.client(Creepy.config('twitter', {}))
      @hooks = Hooks.new(Creepy.config('tasks.stream.hooks', {}))
    rescue
      shell.error "#{$!.class}: #{$!.message}"
      raise SystemExit
    end

    def trap
      Signal.trap(:HUP) do
        setup
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
      @client.user &method(:hooks)
    rescue
      shell.error "#{$!.class}, #{$!.message}"
    end

    def hooks(status)
      @hooks.call(status)
    rescue
      shell.error "#{$!.class}, #{$!.message}"
    end

    Dir[File.dirname(__FILE__) + '/stream/*.rb'].each {|f| require f}
  end
end
