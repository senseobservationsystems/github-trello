#!/usr/bin/env ruby

require 'github_api'
ARGV.each do|a|
        user,repos = a.split("/")
	puts "Adding hook for repos #{a}"
	github = Github.new #basic_auth: 'user:password'
	config = {"url"=>"http://my.sense-os.nl:5678/issue"}
	result = github.repos.hooks.create user, repos, name: "web", active: true, events:["issues"], config:config
        puts result.inspect
end
