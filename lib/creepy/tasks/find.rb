# -*- coding: utf-8 -*-

module Creepy
  module Tasks
    class Find < Base
      Tasks.add_task :find, self

      desc 'Find tweets'

      DATE_FORMAT = '%Y-%m-%d %H:%M'
      TIME_ZONE   = DateTime.now.zone.to_i.hours

      class_option :screen_name, :aliases => '-n', :type => :string,
        :desc => 'Filter screen_name separated by a comma.'
      class_option :keywords,    :aliases => '-k', :type => :string,
        :desc => 'Filter keywords separated by a comma.'
      class_option :text,        :aliases => '-t', :type => :string,
        :desc => 'A regular expression to filter the text.'

      class_option :deleted,     :aliases => '-d', :type => :boolean, :default => false,
        :desc => 'Show deleted status only.'

      class_option :sort,        :aliases => '-s', :type => :string,  :default => 'id,desc',
        :desc => 'Sort key (Descending), or sort key & direction pair that are separated by a comma.'
      class_option :limit,       :aliases => '-l', :type => :numeric,
        :desc => 'Number of tweets.'

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
          @col.ensure_index([['user.screen_name', Mongo::ASCENDING]])
        end

        if options[:keywords]
          keywords = options[:keywords].split(',')
          @sel['keywords'] = {'$all' => keywords}
          @highlight = Regexp.new('(' + keywords.map {|k| Regexp.escape(k)}.join('|') + ')')
          @col.ensure_index([['keywords', Mongo::ASCENDING]])
        end

        if options[:text]
          text = options[:text]
          @sel['text'] = {'$regex' => text}
          @highlight = Regexp.new('(' + text + ')')
          @col.ensure_index([['text', Mongo::ASCENDING]])
        end

        if options[:deleted]
          sel = {'delete.status' => {'$exists' => true}}
          deleted_ids = @db['delete'].find(sel).to_a.map {|s| s['delete']['status']['id']}
          @sel['id'] = {'$in' => deleted_ids}
          @col.ensure_index([['id', Mongo::DESCENDING]])
        end
      end

      def build_options
        if options[:sort]
          key, direction = *options[:sort].split(',')
          direction = :desc unless direction
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
            text = text.gsub(@highlight, shell.set_color('\1', :red))
          end

          shell.say "#{created_at}: #{screen_name} #{text}"
        end
      end
    end
  end
end
