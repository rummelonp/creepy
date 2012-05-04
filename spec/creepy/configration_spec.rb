# -*- coding: utf-8 -*-

require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Creepy::Configuration do
  after(:each) do
    configatron.reset!
  end

  describe :config do
    it 'Configuration::Store のインスタンスであること' do
      Creepy.config.should be_a Configatron::Store
    end

    it '値が設定出来ること' do
      Creepy.config.hoge.should be_nil
      Creepy.config.hoge = :hoge
      Creepy.config.hoge.should == :hoge
    end
  end

  describe :configure do
    it 'ブロックに Creepy.config が渡されること' do
      Creepy.configure do |config|
        config.should == Creepy.config
      end
    end

    it 'ブロックで値が設定出来ること' do
      Creepy.config.hoge.should be_nil
      Creepy.configure do |config|
        config.hoge = :hoge
      end
      Creepy.config.hoge.should == :hoge
    end
  end

  describe :register_default do
    it 'ブロックに Creepy.config が渡されること' do
      Creepy.register_default do |config|
        config.should == Creepy.config
      end
    end

    it 'ブロックで値が設定出来ること' do
      Creepy.config.hoge.should be_nil
      Creepy.register_default do |config|
        config.hoge = :hoge
      end
      Creepy.config.hoge.should == :hoge
    end

    it 'restore_defaults 時に default が評価されること' do
      dummy = lambda {}
      dummy.should_receive(:call).twice
      Creepy.register_default do
        dummy.call
      end
      Creepy.reload_config!
    end
  end
end
