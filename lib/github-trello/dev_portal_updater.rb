module GithubTrello
  class DevPortalUpdater
    @queue = :devportal

    def self.perform(devportal_path, devportal_pid)
      puts "Updating devportal, path: #{devportal_path}, unicorn pid: #{devportal_pid}" 
      pid = `cat #{devportal_pid}`
      unless pid.empty?

        puts "#{Time.now} update codebase from github"
        cmd = "cd #{devportal_path};git reset --hard HEAD;git pull origin master;"
        puts `#{cmd}`

        puts "#{Time.now} Parse articles into database"
        cmd = "cd #{devportal_path};LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 BUNDLE_GEMFILE='#{devportal_path}/Gemfile' RACK_ENV=production rake build --trace"

        puts `#{cmd}`

        puts "#{Time.now} restart unicorn_devportal service"
        cmd = "kill -HUP #{pid}"
        puts `#{cmd}`
      else
        puts "PID of devportal is empty"
      end
    end
  end
end
