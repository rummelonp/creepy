# -*- coding: utf-8 -*-

require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Creepy::Notifies::ImKayacCom do
  describe :call do
    it 'call メソッドが実装されていること' do
      im_kayac_com = Creepy::Notifies::ImKayacCom.new(username: 'user')
      ImKayac.should_receive(:post).with('user', 'poyo: poyopoyo', {})
      im_kayac_com.call('poyo', 'poyopoyo')
    end
  end
end
