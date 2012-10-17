require "json"
require "sinatra/base"
require "github-trello/version"
require "github-trello/http"


module GithubTrello
  class Server < Sinatra::Base
    post "/posthook" do
      config, http = self.class.config, self.class.http

      payload = JSON.parse(params[:payload])

      board_id = config["board_ids"][payload["repository"]["name"]]
      unless board_id
        puts "[ERROR] Commit from #{payload["repository"]["name"]} but no board_id entry found in config"
        return
      end

      branch = payload["ref"].gsub("refs/heads/", "")
      if config["blacklist_branches"] and config["blacklist_branches"].include?(branch)
        return
      elsif config["whitelist_branches"] and !config["whitelist_branches"].include?(branch)
        return
      end

      payload["commits"].each do |commit|
        # Figure out the card short id
        match = commit["message"].match(/((case|card|close|archive|fix)e?s? \D?([0-9]+))/i)
        next unless match and match[3].to_i > 0

        results = http.get_card(board_id, match[3].to_i)
        unless results
          puts "[ERROR] Cannot find card matching ID #{match[3]}"
          next
        end

        results = JSON.parse(results)

        # Add the commit comment
        message = "#{commit["author"]["name"]}: #{commit["message"]}\n\n[#{branch}] #{commit["url"]}"
        message.gsub!(match[1], "")
        message.gsub!(/\(\)$/, "")

        http.add_comment(results["id"], message)

        # Determine the action to take
        update_config = case match[2].downcase
          when "case", "card" then config["on_start"]
          when "close", "fix" then config["on_close"]
          when "archive" then {:archive => true}
        end

        next unless update_config.is_a?(Hash)

        # Modify it if needed
        to_update = {}

        unless results["idList"] == update_config["move_to"]
          to_update[:idList] = update_config["move_to"]
        end

        if !results["closed"] and update_config["archive"]
          to_update[:closed] = true
        end

        unless to_update.empty?
          http.update_card(results["id"], to_update)
        end
      end

      ""
    end

    post "/deployed/:repo" do
      config, http = self.class.config, self.class.http
      if !config["on_deploy"]
        raise "Deploy triggered without a on_deploy config specified"
      elsif !config["on_close"] or !config["on_close"]["move_to"]
        raise "Deploy triggered and either on_close config missed or move_to is not set"
      end

      update_config = config["on_deploy"]

      to_update = {}
      if update_config["move_to"] and update_config["move_to"][params[:repo]]
        to_update[:idList] = update_config["move_to"][params[:repo]]
      end

      if update_config["archive"]
        to_update[:closed] = true
      end

      cards = JSON.parse(http.get_cards(config["on_close"]["move_to"]))
      cards.each do |card|
        http.update_card(card["id"], to_update)
      end

      ""
    end

    post "/issue" do
      config, http = self.class.config, self.class.http

      payload = JSON.parse(params[:payload])

      #For now only handle newly created issues
      if (payload["action"] != "opened")
        puts "Not handling issue #{payload["action"]}."
        return
      end

      repos = payload["repository"]["full_name"]
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
      issue = payload["issue"]
      card_name = "#{issue["title"]}"
      card_desc = "#{issue["body"]}\n\nGithub [issue #{issue["number"]}](#{issue["html_url"]})"
      card = {}
      card[:name] = card_name
      card[:desc] = card_desc
      card[:idList] = list_id
      puts "Posting card #{card.inspect}."
      http.add_card(card)

      ""
    end

    get "/" do
      ""
    end

    def self.config=(config)
      @config = config
      @http = GithubTrello::HTTP.new(config["oauth_token"], config["api_key"])
    end

    def self.config; @config end
    def self.http; @http end
  end
end
