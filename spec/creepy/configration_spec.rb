# -*- coding: utf-8 -*-

require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Creepy::Configuration do
  describe :config do
    it 'Configuration::Store のインスタンスであること' do
      Creepy.config.should be_a Configatron::Store
    end

  end

  describe :configure do
    it 'ブロックに Creepy.config が渡されること' do
      Creepy.configure do |config|
        config.should == Creepy.config
      end
    end
  end
end
