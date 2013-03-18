require 'spec_helper'

describe NotifyOn::DSL, :ar => true do
  class Post < ActiveRecord::Base
    notify_on :title, :comments_count
  end

  subject { Post.first }

  describe 'methods' do
    describe 'objects' do
      it 'should not add the notify on method' do
        Object.methods.should_not include(:notify_on)
      end
    end

    describe ActiveRecord::Base do
      it 'should add the notify on method' do
        ActiveRecord::Base.methods.should include(:notify_on)
      end

      it 'should add the perform notifications method' do
        Post.new.methods.should include(:perform_notifications)
      end

      it 'should have_many subscriptions :as => :model' do
        assoc = Post.reflect_on_association(:subscriptions)

        assoc.association_class.should == ActiveRecord::Associations::HasManyAssociation
        assoc.klass.should == NotifyOn::Subscription

        assoc.type.should == 'model_type'
      end

      it 'should have_many notifications through subscriptions' do
        assoc = Post.reflect_on_association(:notifications)

        assoc.association_class.should == ActiveRecord::Associations::HasManyThroughAssociation
        assoc.klass.should == NotifyOn::Notification
      end
    end
  end

  describe '.notify_on' do
    describe 'options' do
      it 'should have the options' do
        Post.notification_options.should == {
          :attrs => %w(title comments_count)
        }
      end
    end
  end

  describe '#save' do
    let(:async) { subject.async.tap {|a| subject.stub(:async).and_return(a) } }
    let(:save) { subject.save }

    it 'should not notify' do
      async.should_not_receive(:perform_notifications)

      save
    end

    describe 'when the given attributes have changed' do
      before do
        subject.title = 'My new title!'
      end

      describe 'when there are subscriptions' do
        before do
          subject.subscriptions.should have(1).items
        end

        it 'should notify asynchronously' do
          async.should_receive(:perform_notifications)

          save
        end
      end

      describe 'when there are no subscriptions' do
        before do
          subject.subscriptions = []
        end

        it 'should not notify' do
          async.should_not_receive(:perform_notifications)

          save
        end
      end
    end
  end

  # TODO: add support for sending the changes through to the notifier

  describe '#perform_notifications' do
    let(:perform_notifications) { subject.send(:perform_notifications) }

    before do
      @notifier = mock(NotifyOn::Notifier, :perform => nil)
      NotifyOn::Notifier.stub(:new).and_return(@notifier)
    end

    it 'should create a notifier' do
      NotifyOn::Notifier.should_receive(:new).and_return(@notifier)

      perform_notifications
    end

    it 'should give the model' do
      NotifyOn::Notifier.should_receive(:new).with(subject).and_return(@notifier)

      perform_notifications
    end

    it 'should perform the notification' do
      @notifier.should_receive(:perform)

      perform_notifications
    end
  end
end
