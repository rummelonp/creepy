# -*- coding: utf-8 -*-

module Creepy
  module Tasks
    class Find < Base
      Tasks.add_task :find, self

      desc 'Find tweets from query'

      DATE_FORMAT = '%Y-%m-%d %H:%M'
      TIME_ZONE   = DateTime.now.zone.to_i.hours

      class_option :screen_name, :aliases => '-n', :type => :string
      class_option :keywords,    :aliases => '-k', :type => :string
      class_option :text,        :aliases => '-t', :type => :string

      class_option :deleted,     :aliases => '-d', :type => :boolean, :default => false

      class_option :sort,        :aliases => '-s', :type => :string,  :default => 'id,desc'
      class_option :limit,       :aliases => '-l', :type => :numeric

      def setup
        @db = Creepy.config.mongo.db
        @col = @db['status']
        @sel = {}
        @opts = {}
        @highlight = nil
      end

      def build_selecter
        if options[:screen_name]
          users = options[:screen_name].split(',')
          @sel['user.screen_name'] = {'$in' => users}
        end
        if options[:keywords]
          keywords = options[:keywords].split(',')
          @sel['keywords'] = {'$all' => keywords}
          @highlight = Regexp.new('(' + keywords.map {|k| Regexp.escape(k)}.join('|') + ')')
        end
        if options[:text]
          text = options[:text]
          @sel['text'] = {'$regex' => text}
          @highlight = Regexp.new('(' + text + ')')
        end
        if options[:deleted]
          sel = {'delete.status' => {'$exists' => true}}
          deleted_ids = @db['delete'].find(sel).to_a.map {|s| s['delete']['status']['id']}
          @sel['id'] = {'$in' => deleted_ids}
        end
      end

      def build_options
        if options[:sort]
          key, direction = *options[:sort].split(',')
          @opts[:sort] = [key, direction]
        end
        if options[:limit]
          @opts[:limit] = options[:limit]
        end
      end

      def find
        @col.find(@sel, @opts).each do |status|
          created_at = (DateTime.parse(status['created_at']) + TIME_ZONE).strftime(DATE_FORMAT)
          screen_name = ('@' + status['user']['screen_name'] + ':').ljust(18)
          text = status['text'].gsub(/\n?$/, "\n")
          if @highlight
            text = text.gsub(@highlight, shell.set_color('\1',:red))
          end
          shell.say "#{created_at}: #{screen_name} #{text}"
        end
      end
    end
  end
end
