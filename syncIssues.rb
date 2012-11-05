#!/usr/bin/env ruby

require "yaml"
require 'github_api'
require 'sqlite3'
require 'json'
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
	issues = github.issues.list_repo user, repos
	#select open, new issues
	open_issues = issues.select {|issue| issue['state'] == 'open' and db.execute("SELECT COUNT(1) FROM cards WHERE issue_id == #{issue['id']}")[0][0] == 0}
	puts "Found #{open_issues.count} new open issues in #{a}.\n"

	open_issues.each do |issue|
      # find repository type (backend, api lib, etc)
      repo_name = a
      repo_url = repos_url
      repo_type = config["repo_types"][repo_name]
      unless repo_type
        repo_type = config["repo_types"]["default"]
      end

      # see if the issue has been labeled as an enhancement in GitHub
      labels = issue["labels"]
      is_enhancement = false
      labels.each do|label|
        if label["name"] == "enhancement"
          is_enhancement = true
        end
      end
      
      # get the proper Trello list ID from the config
      if is_enhancement
        list_id = config["inbox_lists"][repo_type]
      else
        list_id = config["bugs_lists"][repo_type]
      end
      unless list_id
        puts "[ERROR] Issue from #{repo_name} but no list_id entry nor default entry found in config"
        return
      end

      # parse issue to create a nice card name and description with a link to the issue
      if is_enhancement
        card_name = "#{issue["title"]}"
      else
        card_name = "Bug: #{issue["title"]}"
      end
      card_desc = "#{issue["body"]}\n\nGithub [issue #{issue["number"]}](#{issue["html_url"]}) in [#{repo_name}](#{repo_url})."
      card = {}
      card[:name] = card_name
      card[:desc] = card_desc
      card[:idList] = list_id
      puts "Posting card #{card.inspect}."
      response = http.add_card(card)
			response = JSON.parse(response)
			if (response and response.has_key? 'id')
				card_id = response['id']
				#add to database as well
				puts "Putting (#{card_id},#{issue['id']}) into database.\n"
				db.execute("insert into cards (card_id,issue_id) values ('#{card_id}','#{issue['id']}')")
			end

	end
end
