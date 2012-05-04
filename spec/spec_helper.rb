# -*- coding: utf-8 -*-

root = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift File.join(root, 'lib')
ENV['BUNDLE_GEMFILE'] ||= File.join(root, 'Gemfile')

require 'rubygems'
require 'bundler'
Bundler.require
require 'creepy'

def create_credentials(screen_name)
  Hashie::Mash.new({
    screen_name: screen_name
  })
end

def create_status(screen_name, text, source = '')
  Hashie::Mash.new({
    text: text,
    user: {
      screen_name: screen_name,
    },
    source: source
  })
end

def create_event_status(screen_name, event, text)
  Hashie::Mash.new({
    event: event,
    target_object: {
      text: text
    },
    source: {
      screen_name: screen_name,
    }
  })
end

