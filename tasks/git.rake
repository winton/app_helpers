namespace :plugins do
  task :update => 'app_helpers:git:plugins:update'
end

namespace :app_helpers do
  
  desc 'Copies git assets to app'
  task :git => [ 'app_helpers:git:ignore', 'app_helpers:git:plugins' ]
  
  namespace :git do

    desc 'Initiates git pull on all git repositories'
    task :pull do
      Dir["**/*/.git"].collect do |f|
        puts f
        `cd #{File.dirname(f)}; git checkout master; git pull`
      end
    end
    
    desc 'Copies .gitignore to app'
    task :ignore do
      app_helper_resource 'git/ignore', '.gitignore'
    end
    
    desc 'Copy config/plugins.rb to app'
    task :plugins do
      app_helper_resource 'git/plugins.rb', 'config/plugins.rb'
    end
    
    namespace :plugins do
      desc 'Clones git repositories to vendor/plugins'
      task :update do
        eval(File.read('config/plugins.rb')).each do |url|
          puts url
          if url.include?('@')
            dir = "vendor/plugins/#{File.basename(url, '.git')}"
            unless File.exists?(dir)
              `git clone #{url} #{dir}`
            end
          else
            `ruby script/plugin install #{url}`
          end
        end
        Dir["#{RAILS_ROOT}/**/*/.git"].each do |dir|
          puts dir
          `cd #{dir}/../; git checkout master; git pull origin master`
        end
      end
    end 
  end
end