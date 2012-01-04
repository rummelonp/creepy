# -*- coding: utf-8 -*-

twitter = Creepy.config('twitter', {})

[Twitter, UserStream].each do |klass|
  klass.configure do |config|
    [:consumer_key,
     :consumer_secret,
     :oauth_token,
     :oauth_token_secret
    ].each do |key|
      config.send "#{key}=", twitter[key]
    end
  end
end
