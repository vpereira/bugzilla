# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

desc 'Open an irb session preloaded with ruby-bugzilla'
task :console do
  sh 'irb -rubygems -I lib -r bugzilla.rb'
end

task default: :spec
