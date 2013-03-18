module NotifyOn
  class Subscription < ::ActiveRecord::Base
    belongs_to :notification
    belongs_to :model, :polymorphic => true

    validates :notification, :model, :presence => true
  end
end
