namespace :app_helpers do
  
  desc 'Copies git assets to app'
  task :git => [ 'app_helpers:git:ignore', 'app_helpers:git:plugins', 'app_helpers:git:plugins:install' ]
  
  namespace :git do
    
    desc 'Copies .gitignore to app'
    task :ignore do
      unless File.exists?('.gitignore')
        app_helper_resource 'git/ignore', '.gitignore'
      end
    end
    
    desc 'Copy config/plugins.rb to app'
    task :plugins do
      unless File.exists?('config/plugins.rb')
        app_helper_resource 'git/plugins.rb', 'config/plugins.rb'
      end
    end
    
    desc 'Removes files from rake app_helpers:git'
    task :remove do
      `rm .gitignore`
      `rm config/plugins.rb`
    end
    
    namespace :plugins do      
      desc 'Adds plugins defined in config/plugins.rb'
      task :install do
        puts "Review config/plugins.rb. Install plugins now? (y/n)"
        yn = STDIN.gets
        if yn.capitalize == 'Y'
          eval(File.read('config/plugins.rb')).each do |plugin|
            if plugin == 'haml'
              puts plugin
              `haml --rails .`
              next
            end
            puts plugin[:repo]
            install_path = mkdir_p(plugin[:to] || "vendor/plugins/#{File.basename(plugin[:repo], '.git')}")
            Dir.chdir install_path do
              `git init`
              `git remote add origin #{plugin[:repo]}`
              `git pull #{plugin[:depth] ? "--depth #{plugin[:depth]} " : ''}origin #{git_head(plugin)}`
            end
          end
        end
      end
      
      desc 'Updates plugins defined in config/plugins.rb'
      task :update do
        eval(File.read('config/plugins.rb')).each do |plugin|
          puts plugin[:repo]
          Dir.chdir install_path do
            `git pull origin #{git_head(plugin)}`
            `git checkout #{git_head(plugin)}`
          end
        end
      end
      
      desc 'Removes plugins defined in config/plugins.rb'
      task :remove do
        eval(File.read('config/plugins.rb')).each do |plugin|
          puts plugin[:repo]
          rm_rf(plugin[:to] || "vendor/plugins/#{File.basename(plugin[:repo], '.git')}")
        end
      end
      
      def git_head(plugin)
        return "tags/#{plugin[:tag]}"    if plugin[:tag]
        return "tags/#{plugin[:branch]}" if plugin[:branch]
        return 'master'
      end
    end 
  end
end