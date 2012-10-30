require "json"
require "sinatra/base"
require "github-trello/version"
require "github-trello/http"
require "github-trello/dev_portal_updater.rb"
require 'sqlite3'
require "resque"

module GithubTrello
  class Server < Sinatra::Base
    wdir = File.dirname(__FILE__)
		path = File.join(wdir, "../../", "github-trello.db")
		if File.exists?(path)
			db = SQLite3::Database.new(path)
		else
			puts "Ai no database found."
			exit
		end

    post "/issue" do
      config, http = self.class.config, self.class.http

      payload = JSON.parse(params[:payload])

      #For now only handle newly created issues
      if (payload["action"] != "opened")
        puts "Not handling issue #{payload["action"]}."
        return
      end
      issue = payload["issue"]
			
			if (db.execute("SELECT COUNT(1) FROM cards WHERE issue_id == #{issue['id']}")[0][0] != 0)
				puts "Issue with id #{issues['id']} already exists"
				return
			end

      # find repository type (backend, api lib, etc)
      repo_name = payload["repository"]["full_name"]
      repo_url = payload["repository"]["html_url"]
      repo_type = config["repo_types"][repo_name]
      unless repo_type
        repo_type = config["repo_types"]["default"]
      end

      # see if the issue has been labeled as an enhancement in GitHub
      labels = issue["labels"]
      is_enhancement = false
      labels.each do|label|
        if label["name"] == "bug"
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

    post "/devportal" do
      config = self.class.config
      payload = JSON.parse(params[:payload])
      refs = payload["ref"]

      if refs == "refs/heads/master"
        devportal_path = config["developer_portal"]["path"]
        devportal_pid = config["developer_portal"]["pid"]

        Resque.enqueue(GithubTrello::DevPortalUpdater, devportal_path, devportal_pid)
      end
    end

    get "/" do
      ""
    end

    post "/devportal" do
      config = self.class.config
      payload = JSON.parse(params[:payload])
      refs = payload["ref"]

      if refs == "refs/heads/master"
        devportal_path = config["developer_portal"]["path"]
        devportal_pid = config["developer_portal"]["pid"]

        pid = `cat #{devportal_pid}`
        unless pid.empty?
          cmd = "cd #{devportal_path};git pull origin master -f; rake build; kill -HUP #{pid}"
          result = `#{cmd}`
          puts result
        end
      end
    end

    def self.config=(config)
      @config = config
      @http = GithubTrello::HTTP.new(config["oauth_token"], config["api_key"])
    end

    def self.config; @config end
    def self.http; @http end
  end


end
