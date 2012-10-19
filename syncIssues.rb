#!/usr/bin/env ruby

require "yaml"
require 'github_api'
require 'sqlite3'
#require "github-trello/http"
require "#{File.dirname(__FILE__)}/lib/github-trello/http.rb"

wdir = "/var/www/github-trello"
path = File.join(wdir, "trello.yml")
if File.exists?(path)
	config = YAML::load(File.read(path))
else
	puts "Ai no config found"
	exit
end
path = File.join(wdir, "github-trello.db")
if File.exists?(path)
	db = SQLite3::Database.new(path)
else
	puts "Ai no database found."
	exit
end
http = GithubTrello::HTTP.new(config["oauth_token"], config["api_key"])

github = Github.new #basic_auth: 'user:password'
ARGV.each do|a|
	user,repos = a.split("/")
	repos_url = "https://github.com/#{a}"
	list_id = config["issue_list"][repos]
	unless list_id 
		list_id = config["issue_list"]["default"]
	end
	unless list_id
		puts "[ERROR] Issue from #{repos} but no list_id entry nor default entry found in config"
		return
	end
	issues = github.issues.list_repo user, repos
	#select open, new issues
	open_issues = issues.select {|issue| issue['state'] == 'open' and db.execute("SELECT COUNT(1) FROM cards WHERE issue_id == #{issue['id']}")[0][0] == 0}
	puts "Found #{open_issues.count} new open issues in #{a}.\n"

	open_issues.each do |issue|
		#create card
		card_name = "#{issue["title"]}"
		card_desc = "#{issue["body"]}\n\nGithub [issue #{issue["number"]}](#{issue["html_url"]}) in [#{a}](#{repos_url})."
		card = {}
		card[:name] = card_name
		card[:desc] = card_desc
		card[:idList] = list_id
		puts "\tPosting card #{card.inspect}.\n"
		response = http.add_card(card)
		puts response.inspect
		if (response and response.has_key? 'id')
			card_id = response['id']
			#add to database as well
			puts "Putting (#{card_id},#{issue['id']}) into database.\n"
			db.execute("insert into cards (card_id,issue_id) values ('#{card_id}','#{issue['id']}')")
			#add label
			label = config['repos_labels'][repos]
			unless label
				label = config['repos_labels']['default']
			end
			if (label)
				http.add_label card_id, label
			end

		end
	end
end
