source "http://rubygems.org"

group :development, :test do
  gem 'rake',                   :require => false
  gem 'rspec-puppet',           :require => false, :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem 'puppetlabs_spec_helper', :require => false
  gem 'puppet-lint',            :require => false
  gem 'puppet-syntax',          :require => false
  gem 'travis-lint',            :require => false
end

group :development do
  gem 'beaker',                 :require => false, :git => 'https://github.com/puppetlabs/beaker', :ref => 'dbac20fe9'
  gem 'beaker-rspec',           :require => false
  gem 'vagrant-wrapper',        :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
