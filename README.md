# NotifyOn

[![Build Status](https://travis-ci.org/bnorton/notify_on.png)](https://travis-ci.org/bnorton/notify_on)

## Installation

Add this line to your application's Gemfile:

    gem 'notify_on'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install notify_on

## Usage

```ruby
class Post < ActiveRecord::Base
  notify_on :title, :body, :comments_count => { :every => 2 }
end

post = Post.first

post.notifications
#=> [#<Notification id: 12, url: "http://callbacks.their-site.com/posts">]

post.update_attributes(:title => updated_title)
#=> true # and sends the notification

post.comments.create(params[:comment])
#=> #<Comment id: 2 ...> # no notification sent

post.comments.create(params[:comment])
#=> #<Comment id: 3 ...> # notification is sent
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
