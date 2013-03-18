require 'spec_helper'

describe NotifyOn::Notification, :ar => true do
  subject { NotifyOn::Notification.first }

  it { should be_valid }

  describe 'validations' do
    it 'should require a url' do
      subject.url = nil
      should_not be_valid

      subject.url = 'http://nofity.my-site.com'
      should be_valid
    end
  end

  describe '#build_request' do
    let(:build_request) { subject.build_request }

    it 'should create a new request' do
      Typhoeus::Request.should_receive(:new)

      build_request
    end

    it 'should request the url' do
      Typhoeus::Request.should_receive(:new).with(subject.url, anything)

      build_request
    end

    it 'should POST' do
      Typhoeus::Request.should_receive(:new).with(anything, hash_including(:method => :post))

      build_request
    end

    it 'should return the request' do
      request = mock(Typhoeus::Request)
      Typhoeus::Request.stub(:new).and_return(request)

      build_request.should == request
    end

    describe 'when the url changes' do
      before do
        subject.url = 'my.new.url'
      end

      it 'should request the new url' do
        Typhoeus::Request.should_receive(:new).with('my.new.url', anything)

        build_request
      end
    end
  end
end
