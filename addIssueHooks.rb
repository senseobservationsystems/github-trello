#!/usr/bin/env ruby

require 'github_api'

github = Github.new #basic_auth: 'user:password'
ARGV.each do|a|
        user,repos = a.split("/")
	puts "Adding hook for repos #{a}"
	config = {"url"=>"http://my.sense-os.nl:5678/issue"}
	result = github.repos.hooks.create user, repos, name: "web", active: true, events:["issues"], config:config
        puts result.inspect
end
