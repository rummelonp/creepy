# -*- coding: utf-8 -*-

require 'digest/sha1'

module Creepy
  module Notifies
    class ImKayacCom
      attr_accessor :username, :password, :sig_key

      extend Creepy::Configuration

      def initialize(options = {})
        @username = options[:username]
        @password = options[:password]
        @sig_key  = options[:sig_key]
      end

      def call(title, message, options = {})
        message = "#{title}: #{message}"

        if @sig_key && !options[:sig]
          options[:sig] = Digest::SHA1.hexdigest(message + @sig_key)
        elsif @password && !options[:password]
          options[:password] = @password
        end

        ImKayac.post(username, message, options)
      end
    end
  end
end
