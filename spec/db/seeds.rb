require 'active_record'

post = Post.where(
  :title => 'Seeded Post'
).first_or_create

notification = NotifyOn::Notification.where(
  :url => 'http://seeded-callback.your-site.com/notifications'
).first_or_create

NotifyOn::Subscription.where(
  :model_id => post.id,
  :model_type => 'Post',
  :notification_id => notification.id
).first_or_create
