# creepy

Twitter のユーザーストリームを受け取ってアレコレするアプリ

## 主な機能

* 指定したキーワード文字列/正規表現にマッチしたツイートの通知
* 指定したイベントの通知
* 全てのステータスの MongoDB への保存

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

config/config.rb のコメント読んでください

## コピーライト

http://sam.zoy.org/wtfpl
