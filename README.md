# creepy

Twitter のユーザーストリームを受け取ってアレコレするアプリ

## 主な機能

* 全てのステータスの MongoDB への保存
* 指定したキーワード文字列/正規表現にマッチしたツイートの通知
* 指定したイベントの通知

## 必要なもの

     Ruby
     MongoDB

### RubyGems

    twitter
    userstream
    mongo
    bson_ext
    natto
    im-kayac
    configatron
    thor
    activesupport
    i18n
    pry

## インストール

    git clone git://github.com/mitukiii/creepy.git
    cd creepy

    # 必要な依存 gem をインストール
    bundle install
    
    # アカウント設定ファイルのサンプルをコピー
    cp config/accounts.yml.sample config/accounts.yml
    
    # Twitter アカウントと im.kaya.com アカウントの設定
    emacs config/accounts.yml
    
    # その他アプリケーションの設定
    emacs config/config.rb

## 使い方

    # ユーザーストリームを受信開始する
    ./creepy.rb stream

## 設定

### 基本事項

設定は config/config.rb ファイルを編集し Ruby で書く  
ハードルは高いがその分自由度も高い

### 受け取ったユーザーストリームのアレコレの設定

Creepy.config.tasks.stream（以下 stream）に設定する

### ユーザーストリーム接続時のパラメータ設定

stream.params がパラメータとしてそのまま送信される

    # 全てのリプライを受け取る
    stream.params[:replies] = :all
    
    # トラッキングするキーワードの設定
    stream.params[:track] = [:twitter, :tumblr]

詳しいことは Twitter の [UserStream の仕様書](https://dev.twitter.com/docs/streaming-api/user-streams) をどうぞ

### 受け取ったユーザーストリームについての設定

stream.hooks に利用する hook を追加していく

### 全てのステータスの MongoDB への保存

stream.hooks に Creepy::Hooks::Mongo クラスのインスタンスを追加する

    # 全てのステータスを種類ごとに collection に分け保存
    stream.hooks << Creepy::Hooks::Mongo.new(Creepy.config.mongo.db)

    # status.text の MeCab による分かち書きを status.keywords に配列として追加して保存
    stream.hooks << Creepy::Hooks::Mongo.with_mecab(Creepy.config.mongo.db)

with_mecab で初期化すれば status.text が分かち書きされた上で保存されるので  
後から検索したい時など役に立つ（かもしれない）

MeCab が入ってない、入れるのが面倒くさい場合は new で初期化すれば良い

### 指定したキーワード文字列/正規表現にマッチしたツイートの通知

stream.hooks に Creepy::Hooks::Keyword クラスのインスタンスを追加する

keyword.include にマッチさせたいキーワード文字列/正規表現を設定  
keyword.exclude に除外したいキーワード文字列/正規表現を設定  
keyword.hooks に keyword と status を受け取る処理を設定  
keyword.notifies に title と message（, options）を受け取る処理を設定

    stream.hooks << Creepy::Hooks::Keyword.new do |keyword|
      # 自分のツイートを除外
      keyword.ignore_self!
      
      # キーワード設定
      keyword.include << 'twitter'
      
      # 除外キーワード設定
      keyword.exclude << /^.*(RT|QT):? @[\w]+.*$/i
      
      ## マッチした keyword と status を keyword collection に保存
      keyword.hooks << lambda do |keyword, status|
        status.keyword = keyword
        config.mongo.db.collection('keyword').insert(status)
      end
      
      ## im.kayac.com に通知
      keyword.notifies << Creepy::Notifies::ImKayacCom.new
      
      ## ログに保存
      log_file = File.join(log_dir, 'creepy.keyword.log')
      logger = Logger.new(log_file)
      keyword.notifies << lambda do |title, message, options = {}|
        logger.info "#{Time.now} #{title}: #{message.gsub(/\n/, ' ')}"
      end
    end

hooks と notifies は  
hooks は生の keyword と status を受け取る  
notifies は keyword と status を元に加工された title と message（, options）を受け取る  
という点で違う

notifies に渡される title と message（, options）は formatter を変更することでカスタマイズすつことも出来る  
デフォルトでは Creepy::Hooks::Keyword::Formatter.default が使用される  
formatter は keyword, status を受け取り [title, message, options] を返す必要がある

formatter をカスタマイズすることにより im.kayac.com での通知時に Tweetbot を開く URL Scheme を追加することも出来る

    stream.hooks << Creepy::Hooks::Keyword.new do |keyword|
      ...
      keyword.formatter = lambda do |keyword, status|
        title, message, options = Creepy::Hooks::Keyword::Formatter.default.call(keyword, status)
        options[:handler] = "tweetbot://#{config.twitter.credentials.screen_name}/status/#{status.id}"
        
        [title, message, options]
      end
      ...
    end

### 指定したイベントの通知

stream.hooks に Creepy::Hooks::Event クラスのインスタンスを追加する  
Creepy::Hooks::Event::Adapter を使って簡単に設定することが出来る

    stream.hooks << Creepy::Hooks::Event.with_adapter do |adapter|
        ## 通知する event を設定
        adapter.notify :reply
        adapter.notify :retweet
        adapter.notify :direct_message
        adapter.notify :favorite
        adapter.notify :unfavorite
        adapter.notify :follow
        adapter.notify :list_member_added
        adapter.notify :list_member_removed
        adapter.notify :list_user_subscribed
        adapter.notify :list_user_unsubscribed

        ## im.kayac.com に通知
        adapter.notifies << Creepy::Notifies::ImKayacCom.new

        ## ログに保存
        log_file = File.join(log_dir, 'creepy.event.log')
        logger = Logger.new(log_file)
        adapter.notifies << lambda do |title, message, options = {}|
          logger.info "#{Time.now} #{title}: #{message.gsub(/\n/, ' ')}"
        end
      end

adapter.notify で通知させたいイベントをシンボルで指定する  
adapter.on でイベントごとの処理をカスタマイズすることも出来る

    stream.hooks << Creepy::Hooks::Event.with_adapter do |adapter|
      ...
      adapter.on(:replay) do |status|
        # リプライを受け取った時にしたい処理を書く
      end
      ...
    end

あるいは全てのイベントを自分でハンドリングすることも出来る

    event_hook = Creepy::Hooks::Event.new
    event_hook.adapter = lambda do |event, status|
      # ここにイベントを受け取った時にしたい処理を書く
    end
    stream.hooks << event_hook

### 自分で hook を書く

status を受け取る call メソッドか実装されたクラスか lambda / proc で処理が書ける

     # 標準出力に受け取ったステータスを表示
     stream.hooks << lambda do |status|
       puts status.inspect
     end

## コピーライト

http://sam.zoy.org/wtfpl
