# -*- coding: utf-8 -*-

module Creepy
  def log_dir
    @log_dir ||= File.join(Creepy.root, 'log')
  end

  module Logger
    extend self

    def new(name, *args)
      file = File.join(Creepy.log_dir, name)
      logger = ::Logger.new(file, *args)
      logger.progname = Creepy
      logger.formatter = ::Logger::Formatter.new

      logger
    end
  end

  module SimpleLogger
    extend self

    def new(name, *args)
      file = File.join(Creepy.log_dir, name)
      ::Logger.new(file, *args)
    end
  end

  register_default do |config|
    config.set_default :logger, Creepy::Logger.new('creepy.log')
  end

  def logger
    config.logger
  end
end
