require 'spec_helper'

describe NotifyOn::Subscription do
  subject { NotifyOn::Subscription.first }

  it { should be_valid }

  describe 'validations' do
    it 'should require a model' do
      subject.model = nil
      should_not be_valid

      subject.model = Post.first
      should be_valid
    end

    it 'should require a notification' do
      subject.notification = nil
      should_not be_valid

      subject.notification = NotifyOn::Notification.first
      should be_valid
    end
  end
end
