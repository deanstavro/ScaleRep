source 'https://rubygems.org'
ruby '2.4.2'

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem "activeadmin", git: "https://github.com/gregbell/active_admin"
gem 'frontend-generators'
gem 'bootstrap', '~> 4.1.0'
gem 'autoprefixer-rails'
gem 'devise'
gem 'high_voltage'
gem 'better_errors'
gem 'rails_layout'
gem 'chartkick'
gem 'groupdate'
gem 'airrecord'
gem 'rails_refactor'
gem 'country-select'
gem 'rest-client'
gem 'sidekiq'
gem 'rails_12factor'
gem 'will_paginate', '~> 3.1.0'

group :test do
  gem 'sqlite3'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
end

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'sqlite3'
  gem 'factory_girl_rails', :require => true
  gem 'faker'
  gem 'rspec-rails'
  gem 'rails-erd'
end

group :development do
  gem 'sqlite3'
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
  gem 'spring-commands-rspec'
  gem "binding_of_caller"
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
end
