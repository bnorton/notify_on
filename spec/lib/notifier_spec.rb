require 'spec_helper'

describe NotifyOn::Notifier do
  let(:post) { mock(Post, :notifications => []) }
  let(:changes) { {'id' => 123, 'title' => 'The new Title!!' } }

  subject { NotifyOn::Notifier.new(post, changes) }

  describe '#model' do
    it 'should expose the given object' do
      subject.model.should == post
    end
  end

  describe '#perform' do
    let(:requests) { 2.times.map {|i| mock("Request #{i}", :options => {})} }
    let(:notifications) { 2.times.map {|i| mock("Notification #{i}", :build_request => requests[i])} }
    let(:post) { mock(Post, :notifications => notifications) }

    let(:perform) { subject.perform }

    before do
      @queue = mock(Typhoeus::Hydra, :queue => nil, :run => nil)
      Typhoeus::Hydra.stub(:new).and_return(@queue)
    end

    it 'should create a multi-request queue' do
      Typhoeus::Hydra.should_receive(:new).and_return(@queue)

      perform
    end

    it 'should not run the queue' do
      @queue.should_receive(:run)

      perform
    end

    it 'should build the requests' do
      notifications.each {|s| s.should_receive(:build_request) }

      perform
    end

    it 'should add the changes into the request options' do
      perform

      requests.map(&:options).uniq.should == [:body => changes]
    end

    it 'should enqueue the requests' do
      @queue.should_receive(:queue).with(requests.first)
      @queue.should_receive(:queue).with(requests.last)

      perform
    end
  end
end
