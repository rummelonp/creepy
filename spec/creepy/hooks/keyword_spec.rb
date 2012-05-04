# -*- coding: utf-8 -*-

require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Creepy::Hooks::Keyword do
  context '@include=["たーねこ"] @exlucde=["はうすなう"]' do
    before do
      @credentials = create_credentials('mitukiii')
      @keyword = Creepy::Hooks::Keyword.new
      @keyword.stub!(:credentials).and_return(@credentials)
      @keyword.include << 'たーねこ'
      @keyword.exclude << 'はうすなう'
      @hook = lambda {|keyword, status|}
      @keyword.hooks << @hook
      @notify = lambda{|title, message, options|}
      @keyword.notifies << @notify
    end

    context '自分の "たーねこいんざおうちなうよー" というツイート' do
      it 'マッチすること' do
        status = create_status('mitukiii', 'たーねこいんざおうちなうよー')
        @hook.should_receive(:call)
          .with('たーねこ', status)
        @keyword.formatter.should_receive(:call)
          .with('たーねこ', status)
          .and_return(['@mitukiii: "たーねこ"', 'たーねこいんざおうちなうよー', {}])
        @notify.should_receive(:call)
          .with('@mitukiii: "たーねこ"', 'たーねこいんざおうちなうよー', {})
        @keyword.call(status)
      end

      context :ignore_self! do
        it 'マッチしないこと' do
          @keyword.ignore_self!
          status = create_status('mitukiii', 'たーねこいんざおうちなうよー')
          @hook.should_not_receive(:call)
          @keyword.formatter.should_not_receive(:call)
          @notify.should_not_receive(:call)
          @keyword.call(status)
        end

        after do
          @keyword.ignore_self = false
        end
      end
    end

    context '自分の "たーねこいんざはうすなうよー" というツイート' do
      it 'マッチしないこと' do
        status = create_status('mitukiii', 'たーねこいんざはうすなうよー')
        @hook.should_not_receive(:call)
        @keyword.formatter.should_not_receive(:call)
        @notify.should_not_receive(:call)
        @keyword.call(status)
      end
    end
  end

  describe :Formatter do
    before do
      @status = create_status('mitukiii',
                              'たーねこいんざおうちなうよー' * 4,
                              '<a href="http://sites.google.com/site/yorufukurou/" rel="nofollow">YoruFukurou</a>')
    end

    describe :default do
      it 'default のフォーマット' do
        formatter = Creepy::Hooks::Keyword::Formatter.default
        title, message = formatter.call('たーねこ', @status)
        title.should == '@mitukiii "たーねこ"'
        message.should == "#{'たーねこいんざおうちなうよー' * 4} from YoruFukurou"
      end
    end

    describe :simple do
      it 'simple なフォーマット' do
        formatter = Creepy::Hooks::Keyword::Formatter.simple
        title, message = formatter.call('たーねこ', @status)
        title.should == '@mitukiii "たーねこ"'
        message.should == "たーねこいんざおうちなうよーたーねこいんざおうちなうよーたーねこいんざおう..."
      end
    end
  end
end
