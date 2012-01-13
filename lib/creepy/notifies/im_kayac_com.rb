# -*- coding: utf-8 -*-

require 'digest/sha1'

class Creepy::Notifies
  class ImKayacCom
    Creepy::Notifies.add :im_kayac_com, self

    def initialize(options = {})
      @config = Creepy.config('notifies.im_kayac_com', {}).merge(options)
    end

    def notify(title, message, options = {})
      message = "#{title}: #{message}"
      options = @config.merge(options)
      username = options.delete(:username)

      if options[:sig_key] && !options[:sig]
        sig_key = options.delete(:sig_key).to_s
        options[:sig] = Digest::SHA1.hexdigest(message + sig_key)
      end

      ::ImKayac.post(username, message, options)
    end
  end
end
