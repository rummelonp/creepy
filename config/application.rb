# -*- coding: utf-8 -*-

@config = Creepy::ConfigLoader.load

[Twitter, UserStream].each do |klass|
  klass.configure do |config|
    [:consumer_key,
     :consumer_secret,
     :oauth_token,
     :oauth_token_secret
    ].each do |key|
      config.send "#{key}=", @config[key]
    end
  end
end
