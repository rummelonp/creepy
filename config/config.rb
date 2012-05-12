# -*- coding: utf-8 -*-

require 'yaml'

Creepy.configure do |config|
  ## タスクの設定
  config.tasks do |tasks|
    ## Stream タスクの設定
    tasks.stream do |stream|
      ## パラメータの設定
      stream.params[:replies] = :all

      ## MongoDB に保存
      stream.hooks << Creepy::Hooks::Mongo.with_mecab(Creepy.db)

      ## Keyword 通知
      stream.hooks << Creepy::Hooks::Keyword.new do |keyword|
        keyword.include << 'twitter'
        keyword.exclude << /^.*(RT|QT):? @[\w]+.*$/i
        keyword.hooks << lambda do |keyword, status|
          status.keyword = keyword
          Creepy.db.collection('keyword').insert(status)
        end

        ## im.kayac.com に通知
        keyword.notifies << Creepy.im_kayac_com

        ## ログに保存
        logger = Creepy::SimpleLogger.new('creepy.keyword.log')
        keyword.notifies << lambda do |title, message, options = {}|
          logger.info "#{Time.now} #{title}: #{message.gsub(/\n/, ' ')}"
        end
      end

      ## Event 通知
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
        adapter.notifies << Creepy.im_kayac_com

        ## ログに保存
        logger = Creepy::SimpleLogger.new('creepy.event.log')
        adapter.notifies << lambda do |title, message, options = {}|
          logger.info "#{Time.now} #{title}: #{message.gsub(/\n/, ' ')}"
        end
      end
    end
  end
end
