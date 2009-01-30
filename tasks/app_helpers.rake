install_tasks = [ 'app_helpers:db', 'app_helpers:git', 'app_helpers:views', 'app_helpers:widgets' ]
remove_tasks =  [ 'app_helpers:db:remove', 'app_helpers:git:plugins:remove', 'app_helpers:git:remove', 'app_helpers:views:remove', 'app_helpers:widgets:remove' ]

desc 'Copy database config, git assets, views, widget assets'
task :app_helpers => install_tasks

namespace :plugins do
  desc 'Adds plugins defined in config/plugins.rb'
  task :install => 'app_helpers:git:plugins:install'
  
  desc 'Updates plugins defined in config/plugins.rb'
  task :update  => 'app_helpers:git:plugins:update'
  
  desc 'Removes plugins defined in config/plugins.rb'
  task :remove  => 'app_helpers:git:plugins:remove'
end

namespace :app_helpers do
  
  desc 'Removes files created by rake app_helpers'
  task :remove => remove_tasks
  
  desc 'Reinstall files created by rake app_helpers'
  task :reinstall do
    `rm -Rf vendor/plugins/app_helpers`
    `git clone git@github.com:winton/app_helpers.git vendor/plugins/app_helpers`
    Rake::Task['app_helpers:remove'].invoke
    Rake::Task['app_helpers'].invoke
  end
    
  def app_helper_resource(type, to, reverse=false, overwrite=true)
    from = "#{File.dirname(__FILE__)}/../resources/#{type}"
    from, to = to, from if reverse
    return if File.exists?(to) && !overwrite
    puts "=> Removing old #{type}..."
    puts to
    if File.directory?(from)
      FileUtils.remove_dir(to, true) if File.exists?(to)
      FileUtils.mkdir_p to
    else
      File.unlink(to) if File.exists?(to)
    end
    puts "=> Copying #{type}..."
    (File.directory?(from) ? Dir["#{from}/*"] : [from]).each do |f|
      if File.directory? f
        FileUtils.mkdir_p "#{to}/#{File.basename(f)}"
        FileUtils.cp_r f, to
      else
        FileUtils.cp f, to
      end
    end if File.exists?(from)
  end
  
end
