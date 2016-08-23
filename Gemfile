source 'http://rubygems.org'

gem 'rails', '3.2.21'
gem 'rake', '10.0.4'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
group :development do
  gem 'sqlite3'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "meta_request"
  gem 'railroady'
  gem 'rack-mini-profiler'
end

group :production do
  gem 'pg'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer'
  gem 'less-rails'
  gem 'compass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

#
# Testing frameworks
#
group :test, :development do
  gem "rspec"
  gem "rspec-rails", "~> 2.0"
  gem 'simplecov', :require => false
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'thin'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'pry'
  #gem 'mocha'
end

#
# Assets, front-end related gems
#
gem "twitter-bootstrap-rails", "~> 2.2.8"
gem 'twitter-bootstrap-calendar'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'will_paginate-bootstrap', "= 0.2.3"

#
# User layer ( authentication, authorization and )
#
gem 'devise'
gem "rolify"
gem "paper_trail", "~> 2.6.4"
gem "paperclip", "~> 3.0"
gem "watu_table_builder", :require => "table_builder"

#
# Other gems
#
gem 'whenever', :require => false  # for writing and deploying cron jobs.
gem 'spreadsheet', '0.9.0'
gem 'roo' # access Open-office (.ods) Excel (.xls, .xlsx) & Google (online) spreadsheets
gem 'cocaine', '0.3.2' #A small library for doing (command) lines.
gem 'will_paginate', '~> 3.0.0'
gem 'english_county_select'
gem 'valid_email'
gem 'validates_timeliness', '~> 3.0'
gem 'haml'
gem 'draper', '~> 1.0' #adds an object-oriented layer of presentation logic to your Rails application.
gem 'simple_form'
gem 'prawn' # PDF writing
gem 'prawnto' # PDF writing in views
gem 'rmagick', '2.13.2', require: false # used to convert BMP logos to JPG format for PDF writing
gem 'delayed_job_active_record' # background long-running jobs
gem 'daemons' # required by delayed job to run background processes
gem 'acts_as_tree'
gem 'dropzonejs-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'

# To use debugger
# gem 'debugger'

gem 'airbrake'

# New Relic App Monitoring

gem 'newrelic_rpm'

# Maintenence Mode

gem 'turnout'

gem 'net-ssh'
gem 'net-scp'

