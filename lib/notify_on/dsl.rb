module NotifyOn
  module DSL
    def notify_on(*attrs)
      self.class_attribute :notification_options
      self.send(:extend, ClassMethods)
      self.send(:include, InstanceMethods)

      attrs_with_options = (attrs.last.is_a?(Hash) && attrs.pop) || {}

      self.notification_options = {
        :attrs => (attrs + attrs_with_options.keys).map(&:to_s)
      }
    end

    module ClassMethods
      def self.extended(base)
        base.worker :perform_notifications
        base.has_many :subscriptions, :as => :model, :class_name => 'NotifyOn::Subscription'
        base.has_many :notifications, :through => :subscriptions, :class_name => 'NotifyOn::Notification'

        base.after_save -> { self.async.perform_notifications }, :if => -> {
          (self.changed & self.class.notification_options[:attrs]).any? && self.subscriptions.any?
        }
      end
    end

    module InstanceMethods
      def perform_notifications
        NotifyOn::Notifier.new(self).perform
      end
    end
  end
end

ActiveRecord::Base.send(:extend, NotifyOn::DSL)
