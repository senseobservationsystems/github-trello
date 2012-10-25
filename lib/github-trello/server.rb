require "json"
require "sinatra/base"
require "github-trello/version"
require "github-trello/http"
require 'sqlite3'

module GithubTrello
  class Server < Sinatra::Base
		wdir = "/var/www/github-trello"
		path = File.join(wdir, "github-trello.db")
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

      repos = payload["repository"]["full_name"]
      repos_url = payload["repository"]["html_url"]
      puts config["issue_list"].inspect
      list_id = config["issue_list"][repos]
      unless list_id 
        list_id = config["issue_list"]["default"]
      end
      unless list_id
        puts "[ERROR] Issue from #{repos} but no list_id entry nor default entry found in config"
        return
      end

      #parse issue to create a nice card name and description with a link to the issue
      card_name = "#{issue["title"]}"
      card_desc = "#{issue["body"]}\n\nGithub [issue #{issue["number"]}](#{issue["html_url"]}) in [#{repos}](#{repos_url})."
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
				#add label
				label = config['repos_labels'][repos]
				unless label
					label = config['repos_labels']['default']
				end
				puts "Found label #{label} for issue"
				if (label)
					response = http.add_label card_id, label
					puts response.inspect
				end
			end

      ""
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
