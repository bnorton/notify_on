require 'spec_helper'

describe 'notifications', :ar => true do
  let(:post) { Post.first }
  let(:notification) { post.notifications.first }

  before do
    Post.any_instance.stub(:async).and_return(post)

    notification.update_attributes!(:url => 'http://notify.my-site.com/posts.json')

    WebMock.stub_request(:post, 'http://notify.my-site.com/posts.json')
  end

  it 'should send notifications on changes' do
    post.title = 'My New Title!!'
    post.save!

    post.comments_count = 1000
    post.save!

    WebMock.should have_requested(:post, 'http://notify.my-site.com/posts.json').with(:body => {:title => 'My New Title!!', :id => post.id, :updated_at => post.updated_at}.to_json)
    WebMock.should have_requested(:post, 'http://notify.my-site.com/posts.json').with(:body => {:comments_count => 1000, :id => post.id, :updated_at => post.updated_at}.to_json)
  end
end
