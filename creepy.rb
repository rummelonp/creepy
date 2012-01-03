# -*- coding: utf-8 -*-

$:.unshift File.expand_path 'lib'
$:.unshift File.expand_path 'config'

require 'rubygems'
require 'bundler'
Bundler.require
require 'creepy'
require 'application'

Creepy::Cli.start ARGV
