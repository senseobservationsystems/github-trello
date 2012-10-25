module GithubTrello
  class DevPortalUpdater
    @queue = :devportal

    def self.perform(devportal_path, devportal_pid)
      puts "Updating devportal" 
      pid = `cat #{devportal_pid}`
      unless pid.empty?
        cmd = "cd #{devportal_path};git reset --hard HEAD;git pull origin master;  LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 RACK_ENV=production rake build; kill -HUP #{pid}"
        result = `#{cmd}`
        puts result
      end
    end
  end
end
