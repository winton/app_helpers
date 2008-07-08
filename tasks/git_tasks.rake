namespace :git do
  
  desc 'Runs all submodule tasks'
  task :submodule => [ 'git:submodule:update', 'git:submodule:pull' ]
  
  namespace :submodule do
    desc 'Runs submodule init and update'
    task :update do
      system "git submodule init"
      system "git submodule update"
    end
    
    desc 'Initiates git pull on all submodules'
    task :pull do
      Dir["vendor/plugins/*/.git", "config/*/.git", "public/javascripts/*/.git"].collect do |f|
        system "cd #{File.dirname(f)}; git pull origin master; git checkout master"
      end
    end
  end
end