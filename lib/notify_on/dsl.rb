module NotifyOn
  module DSL
    def notify_on(*attrs)
      unless self.respond_to?(:notification_options)
        self.class_attribute :notification_options
        self.send(:extend, ClassMethods)
        self.send(:include, InstanceMethods)
      end

      options = (attrs.last.is_a?(Hash) && attrs.pop) || {}
      always  = options.fetch(:always, [])

      self.notification_options = {
        :attrs => attrs.map(&:to_s),
        :always => %w(id) | always.map(&:to_s)
      }
    end

    module ClassMethods
      def self.extended(base)
        base.worker
        base.has_many :subscriptions, :as => :model, :class_name => 'NotifyOn::Subscription'
        base.has_many :notifications, :through => :subscriptions, :class_name => 'NotifyOn::Notification'

        base.after_update -> { self.async.perform_notifications }, :if => -> {
          (self.changed & self.class.notification_options[:attrs]).any? && self.subscriptions.any?
        }
      end
    end

    module InstanceMethods
      def perform_notifications
        options = self.class.notification_options
        keys = changed & options[:attrs]

        NotifyOn::Notifier.new(self, attributes.slice(*(keys + options[:always]))).perform
      end
    end
  end
end

ActiveRecord::Base.send(:extend, NotifyOn::DSL)
