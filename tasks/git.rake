namespace :app_helpers do
  
  desc 'Copies git assets to app'
  task :git => [ 'app_helpers:git:ignore', 'app_helpers:git:plugins' ]
  
  namespace :git do
    desc 'Copies .gitignore to app'
    task :ignore do
      File.unlink '.gitignore'
      app_helper_resource 'git/ignore', ''
      File.rename 'gitignore', '.gitignore'
    end
    
    desc 'Copy config/plugins.rb to app'
    task :plugins do
      app_helper_resource 'git/plugins', 'config'
    end
    
    namespace :plugins do
      desc 'Clones git repositories to vendor/plugins'
      task :install do
        eval(File.read('config/plugins.rb')).each do |url|
          if url.include('@')
            dir = "vendor/plugins/#{File.basename(url, '.git')}"
            FileUtils.rmdir dir
            `git clone #{url} #{dir}`
          else
            `ruby script/plugin install #{url}`
          end
        end
      end
    end 
  end
end