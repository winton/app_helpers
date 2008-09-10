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
      app_helper_resource 'git/plugins.rb', 'config/plugins.rb', false, false
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
        if STDIN.gets.upcase.strip == 'Y'
          eval(File.read('config/plugins.rb')).each do |plugin|
            install_plugin plugin
          end
        end
      end
      
      desc 'Updates plugins defined in config/plugins.rb'
      task :update do
        eval(File.read('config/plugins.rb')).each do |plugin|
          path = install_path plugin
          if File.exists?(path)
            next if plugin == 'haml'
            Dir.chdir path do
              git_fetch_and_checkout plugin
            end
          else
            install_plugin plugin
          end
        end
      end
      
      desc 'Removes plugins defined in config/plugins.rb'
      task :remove do
        eval(File.read('config/plugins.rb')).each do |plugin|
          remove_plugin plugin
        end
      end
      
      def install_path(plugin)
        plugin[:to] || "vendor/plugins/#{plugin == 'haml' ? 'haml' : File.basename(plugin[:repo], '.git')}"
      end
      
      def install_plugin(plugin)
        if plugin[:repo].include?('app_helpers')
          puts "Skipping #{plugin[:repo]}"
          return
        end
        path = remove_plugin plugin
        if plugin == 'haml'
          puts 'Installing haml'
          `haml --rails .`
        else
          puts "Installing #{plugin[:repo]}"
          path = mkdir_p path
          Dir.chdir path do
            `git init`
            `git remote add origin #{plugin[:repo]}`
            git_fetch_and_checkout plugin
          end
        end
      end
      
      def remove_plugin(plugin)
        path = install_path plugin
        return path unless File.exists?(path)
        puts "Removing #{path}"
        rm_rf path
      end
      
      def git_fetch_and_checkout(plugin)
        if plugin[:tag] || plugin[:branch]
          puts "Fetching #{plugin[:repo]}"
          `git fetch #{plugin[:depth] ? "--depth #{plugin[:depth]} " : ''}#{plugin[:tag] ? '-t ' : ''}-q`
        else
          puts "Pulling #{plugin[:repo]}"
          `git pull #{plugin[:depth] ? "--depth #{plugin[:depth]} " : ''}-q origin master`
        end
        puts "Checking out #{git_head(plugin)}"
        `git checkout #{git_head(plugin)} -q`
      end
      
      def git_head(plugin)
        return "tags/#{plugin[:tag]}"      if plugin[:tag]
        return "origin/#{plugin[:branch]}" if plugin[:branch]
        return 'master'
      end
    end 
  end
end