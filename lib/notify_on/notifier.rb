module NotifyOn
  class Notifier
    attr_reader :model

    def initialize(model, changes)
      @model = model
      @changes = changes
    end

    def perform
      model.notifications.each do |notification|
        request = notification.build_request
        request.options[:body] = @changes

        hydra.queue(request)
      end

      hydra.run
    end

    private

    def hydra
      @hydra ||= Typhoeus::Hydra.new
    end
  end
end
