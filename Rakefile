require "bundler"
Bundler.setup

require "rake"
require "resque/tasks"

require "./lib/github-trello/dev_portal_updater"
#require "rspec"
#require "rspec/core/rake_task"

#RSpec::Core::RakeTask.new("spec") do |spec|
#  spec.pattern = "spec/**/*_spec.rb"
#end

GithubTrello::DevPortalUpdater.new

task :default => :spec

task "resque:setup" do
  ENV['QUEUE'] = '*'
end
