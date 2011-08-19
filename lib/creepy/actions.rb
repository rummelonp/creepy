# -*- coding: utf-8 -*-

module Creepy
  module Actions
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def require_arguments!
        @require_arguments = true
      end

      def require_arguments?
        @require_arguments
      end
    end
  end
end

