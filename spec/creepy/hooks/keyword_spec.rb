# -*- coding: utf-8 -*-

require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Creepy::Hooks::Keyword do
  def create_status(screen_name, text, source = '')
    Hashie::Mash.new({
      text: text,
      user: {
        screen_name: screen_name,
      },
      source: source
    })
  end

  context '@include=["たーねこ"] @exlucde=["はうすなう"]' do
    before do
      @keyword = Creepy::Hooks::Keyword.new
      @keyword.include << 'たーねこ'
      @keyword.exclude << 'はうすなう'
      @hook = lambda {|keyword, status|}
      @keyword.hooks << @hook
      @notify = lambda{|title, message|}
      @keyword.notifies << @notify
    end

    it '"たーねこいんざおうちなうよー" にマッチすること' do
      status = create_status('mitukiii', 'たーねこいんざおうちなうよー')
      @hook.should_receive(:call)
        .with('たーねこ', status)
      @keyword.formatter.should_receive(:call)
        .with('たーねこ', status)
        .and_return(['@mitukiii: "たーねこ"', 'たーねこいんざおうちなうよー'])
      @notify.should_receive(:call)
        .with('@mitukiii: "たーねこ"', 'たーねこいんざおうちなうよー')
      @keyword.call(status)
    end

    it '"たーねこいんざはうすなうよー" にマッチしないこと' do
      status = create_status('mitukiii', 'たーねこいんざはうすなうよー')
      @hook.should_not_receive(:call)
      @keyword.formatter.should_not_receive(:call)
      @notify.should_not_receive(:call)
      @keyword.call(status)
    end
  end
end
