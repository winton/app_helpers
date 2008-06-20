namespace :git do
  namespace :submodules do
    desc 'Initiates git pull on all submodules'
    task :pull do
      Dir["vendor/plugins/*/.git", "config/*/.git", "public/javascripts/*/.git"].collect do |f|
        system "cd #{File.dirname(f)}; git pull origin master"
      end
    end
  end
end