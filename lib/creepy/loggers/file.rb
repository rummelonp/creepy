# -*- coding: utf-8 -*-

class Creepy::Loggers
  class File < ::Logger
    Creepy::Loggers.add :file, self

    def initialize(options = {})
      options = Creepy.config('loggers.file', {}).merge(options)

      super(options[:logdev], options[:shift_age])
      self.level = options[:level] || ::Logger::DEBUG

      case options[:format]
      when :simple
        self.formatter = ::Logger::SimpleFormatter.new
      when :default
        self.formatter = nil
      end
    end
  end
end
