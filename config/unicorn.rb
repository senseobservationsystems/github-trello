$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")
require "github-trello/server"
require "yaml"

wdir = "/var/www/github-trello"
path = File.join(wdir, "trello.yml")
    if File.exists?(path)
      GithubTrello::Server.config = YAML::load(File.read(path))
    else
      puts "[WARNING] No configuration found at #{path}."
      puts "We've generated an example one for you, but you need to configure it still."

      config = <<YAML
oauth_token: [token]
api_key: [key]
developer_portal:
  path: "/var/www/developer-portal"
  pid: "/var/www/developer-portal/tmp/pids/unicorn.pid"
on_start:
  move_to: [list id]
  archive: true
on_close:
  move_to: [list id]
  archive: true
# See README for deployment usage
on_deploy:
  move_to:
    [repo name]: [list id]
  archive: true
YAML

      File.open(path, "w+") do |f|
        f.write(config)
      end

      exit
    end

working_directory wdir
pid "/var/www/github-trello/tmp/pids/unicorn.pid"
stderr_path "/var/www/github-trello/tmp/log/unicorn.log"
stdout_path "/var/www/github-trello/tmp/log/unicorn.log"

listen 3000
worker_processes 2
timeout 30
