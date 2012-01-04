# -*- coding: utf-8 -*-

module Creepy
  class Tasks < Mapper
    Dir[File.dirname(__FILE__) + '/tasks/{task}.rb'].each {|f| require f}
    Dir[Dir.pwd + '/tasks/*.rb'].each {|f| require f}
  end
end
