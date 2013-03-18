require 'notify_on'
require 'sqlite3'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true

  config.before :all, :ar => true do
    @_db_name = ENV['TEST_DATABASE'] || File.expand_path('../db/notify_on-test.db', __FILE__)
    File.delete(@_db_name) if File.exists?(@_db_name)

    @_db = SQLite3::Database.new(@_db_name)

    [ 'create table posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title VARCHAR(255),
        comments_count INTEGER
      );','

      create table notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url VARCHAR(255)
      );','

      create table subscriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        notification_id INTEGER,
        model_id INTEGER,
        model_type VARCHAR(255)
      );'].each {|statement| @_db.execute(statement) }

    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database =>  @_db_name
    )

    # Load the base ** fixtures **
    load File.expand_path('../db/seeds.rb', __FILE__)
  end

  config.before :each, :ar => true do
    # ** Transactional fixtures. BEGIN **
    @_db.transaction

  end

  config.after :each, :ar => true do
    # ** Transactional fixtures. ROLLBACK **
    @_db.rollback
  end

  config.after :all, :ar => true do
    File.delete(@_db_name)
  end
end
