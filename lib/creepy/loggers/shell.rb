# -*- coding: utf-8 -*-

class Creepy::Loggers
  class Shell < File
    Creepy::Loggers.add :shell, self

    def initialize(options = {})
      options = Creepy.config('loggers.shell', {}).merge(options)
      super(options.merge(logdev: STDOUT))
    end
  end
end
