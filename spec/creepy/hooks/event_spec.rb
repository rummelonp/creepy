# -*- coding: utf-8 -*-

require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Creepy::Hooks::Event do
  def create_credentials(screen_name)
    Hashie::Mash.new({
      screen_name: screen_name
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

  context 'favorite イベント' do
    before do
      @credentials = create_credentials('mitukiii')
      @event = Creepy::Hooks::Event.new
      @event.stub!(:credentials).and_return(@credentials)
      @event.adapter = Creepy::Hooks::Event::Adapter.new
      @notify = Creepy::Notifies::ImKayacCom.new
      @event.adapter.notifies << @notify
    end

    context '自分からの favorite イベント' do
      before do
        @status = create_event_status('mitukiii', 'favorite', 'たーねこいんざおうちなうよー')
      end

      it 'favorite の handler notifies が呼ばれないこと' do
        on_handler = lambda {|status|}
        @event.adapter.on(:unfavorite, &on_handler)
        notify_handler = lambda {|status|}
        @event.adapter.notify(:unfavorite, &notify_handler)
        on_handler.should_not_receive(:call)
        notify_handler.should_not_receive(:call)
        @notify.should_not_receive(:call)
        @event.call(@status)
      end
    end

    context '他の人からの favorite イベント' do
      before do
        @status = create_event_status(rand.to_s, 'favorite', 'たーねこいんざおうちなうよー')
      end

      it 'favorite の handler と notifies が呼ばれること' do
        on_handler = lambda {|status|}
        @event.adapter.on(:favorite, &on_handler)
        notify_handler = lambda {|status|}
        @event.adapter.notify(:favorite, &notify_handler)
        on_handler.should_receive(:call)
          .with(@status)
        notify_handler.should_receive(:call)
          .with(@status)
          .and_return(['@mitukiii favorite', 'たーねこいんざおうちなうよー'])
        @notify.should_receive(:call)
          .with('@mitukiii favorite', 'たーねこいんざおうちなうよー')
        @event.call(@status)
      end

      it 'unfavorite の handler notifies が呼ばれないこと' do
        on_handler = lambda {|status|}
        @event.adapter.on(:unfavorite, &on_handler)
        notify_handler = lambda {|status|}
        @event.adapter.notify(:unfavorite, &notify_handler)
        on_handler.should_not_receive(:call)
        notify_handler.should_not_receive(:call)
        @notify.should_not_receive(:call)
        @event.call(@status)
      end
    end
  end
end
