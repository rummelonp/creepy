# -*- coding: utf-8 -*-

class Creepy::Tasks
  class Stream < Task
    Creepy::Tasks.add :stream, self

    class_option :daemon, aliases: '-d', default: false, type: :boolean
    class_option :sleep_time, aliases: '-s', default: 60, type: :numeric

    def setup
      Creepy.reload_config!

      @client = UserStream.client(Creepy.config('twitter', {}))
      @logger = Creepy::Loggers.new(Creepy.config('tasks.stream.loggers', {}))
      @hook = Hooks.new(Creepy.config('tasks.stream.hooks', {}))

      @logger.info 'Stream#setup' do
        ["options: {#{options.map{|k,v|k.to_s+': '+v.to_s}.join(', ')}}",
         "outputs: [#{@logger.map(&:class).join(', ')}]",
         "hooks: [#{@hook.map(&:class).join(', ')}]"].join(", ")
      end
    rescue
      @logger.warn('Stream#setup') { "#{$!.message} (#{$!.class})" }
      raise SystemExit
    end

    def trap
      Signal.trap(:HUP) { setup }
    end

    def boot
      if options.daemon?
        @logger.info('Stream#boot') { 'daemon start' }
        Process.daemon
      end
      loop do
        request
        @logger.info('Stream#boot') { "waiting #{options.sleep_time} seconds" }
        sleep options.sleep_time
      end
    end

    private
    def request
      @logger.info('Stream#request') { 'start receive stream' }
      @client.user &method(:read)
    rescue
      @logger.error('Stream#request') { "#{$!.message} (#{$!.class})" }
    end

    def read(status)
      key = %w{friends event delete}.find {|key| status.key? key} || 'status'
      @logger.debug('Stream#read') { "receive #{key} type" }
      @hook.call(key, status)
    rescue
      @logger.error('Stream#read') { "#{$!.message} (#{$!.class})" }
    end

    Dir[File.dirname(__FILE__) + '/stream/*.rb'].each {|f| require f}
  end
end
