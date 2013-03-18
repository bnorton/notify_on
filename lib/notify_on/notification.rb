module NotifyOn
  class Notification < ::ActiveRecord::Base
    before_validation -> { self.url = "http://#{url}" unless url && /https?\:\/\// === url }, :on => :create
    validates :url, :presence => true

    def build_request
      Typhoeus::Request.new(url, :method => :post)
    end
  end
end
