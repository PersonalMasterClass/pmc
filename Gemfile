source 'https://rubygems.org'


# Core 
#--------------------------------------------------------------------
gem 'rails', '4.2.5'
gem 'pg', '~> 0.15'

gem 'devise' 
gem 'simple_form'
gem 'mail_form'
gem "paranoia", "~> 2.0"
gem 'nokogiri'
gem "figaro"
gem 'dragonfly', '~> 1.0.12'
gem 'dragonfly-s3_data_store'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'xeroizer'

# CSS/Layouts
#--------------------------------------------------------------------
gem 'sass-rails', '~> 5.0'
gem 'will_paginate', '~> 3.1.0'
gem "font-awesome-rails"
gem 'tinymce-rails'
gem 'bootstrap-switch-rails'
gem 'bootstrap-sass', '~> 3.3.6'

# Javascript
#--------------------------------------------------------------------
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-ui-rails' 
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'best_in_place'
gem 'jquery-turbolinks'

# Background Processing
#--------------------------------------------------------------------
gem 'resque', :require => "resque/server"
gem 'resque-scheduler'
gem 'resque-scheduler-web'



# Deploy
#--------------------------------------------------------------------

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem "letter_opener"
  gem 'byebug'
  gem 'pry'
  gem "faker"
  gem "capybara"
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails'
  
end

group :production do
  gem 'rails_12factor'
  gem 'therubyracer'
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
end

