# -*- coding: utf-8 -*-

require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Creepy::Hooks::User do
  context '@include=["9m"]' do
    before do
      @user = Creepy::Hooks::User.new
      @user.include << '9m'
      @hook = lambda {|screen_name, status|}
      @user.hooks << @hook
      @notify = lambda{|title, message, options|}
      @user.notifies << @notify
    end

    it '@9m からのツイートにマッチすること' do
      status = create_status('9m', 'あの夏')
      @hook.should_receive(:call)
        .with('9m', status)
      @user.formatter.should_receive(:call)
        .with('9m', status)
        .and_return(['@9m: Say', 'あの夏', {}])
      @notify.should_receive(:call)
        .with('@9m: Say', 'あの夏', {})
      @user.call(status)
    end

    it '@mitukiii からのツイートにマッチしないこと' do
      status = create_status('mitukiii', 'あの夏')
      @hook.should_not_receive(:call)
      @user.formatter.should_not_receive(:call)
      @notify.should_not_receive(:call)
      @user.call(status)
    end
  end

  describe :Formatter do
    before do
      @status = create_status('9m',
                              'あの夏' * 20,
                              '<a href="http://sites.google.com/site/yorufukurou/" rel="nofollow">YoruFukurou</a>')
    end

    describe :default do
      it 'default のフォーマット' do
        formatter = Creepy::Hooks::User::Formatter.default
        title, message = formatter.call('9m', @status)
        title.should == '@9m Say'
        message.should == "#{'あの夏' * 20} from YoruFukurou"
      end
    end

    describe :simple do
      it 'simple なフォーマット' do
        formatter = Creepy::Hooks::User::Formatter.simple
        title, message = formatter.call('9m', @status)
        title.should == '@9m Say'
        message.should == "あの夏あの夏あの夏あの夏あの夏あの夏あの夏あの夏あの夏あの夏あの夏あの夏あ..."
      end
    end
  end
end
