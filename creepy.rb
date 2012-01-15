#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

root = File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(root, 'lib')
$LOAD_PATH.unshift File.join(root, 'config')
ENV['BUNDLE_GEMFILE'] ||= File.join(root, 'Gemfile')

require 'rubygems'
require 'bundler'
Bundler.require
require 'creepy'
require 'config'

Creepy::Tasks::Cli.start ARGV
