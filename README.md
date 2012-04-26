# creepy

Twitter のユーザーストリームを受け取ってアレコレするアプリ

## 主な機能

* 指定したキーワード文字列/正規表現にマッチしたツイートの通知
* 指定したイベントの通知
* 全てのステータスの MongoDB への保存

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
    bundle exec ./creepy.rb stream

## 設定

config/config.rb のコメント読んでください

## 自動起動

### Upstart

    start on runlevel [2345]
    stop on shutdown
    respawn
    
    exec sudo -Hnu #{user} env LANG=ja_JP.UTF-8 `which ruby` #{creepy_root}/creepy.rb stream

\#{user} と #{creepy_root} は適宜読み替えてください  
Upstart が動いてる環境であれば上記のような設定ファイルを  
定義ファイルの入ったディレクトリ（Ubuntu であれば /etc/init）に追加しておけば  
OS 起動時に creepy も自動的に起動するようになります

## 必要なもの

* Ruby
* MongoDB

### RubyGems

* twitter
* userstream
* mongo
* bson_ext
* natto
* im-kayac
* configatron
* thor
* activesupport
* i18n

## コピーライト

http://sam.zoy.org/wtfpl
