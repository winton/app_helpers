desc 'Updates views/shared for all resources'
task :app_helpers => [ 'app_helpers:js_widget', 'app_helpers:tbl', 'app_helpers:template' ]

namespace :app_helpers do  
  desc 'Updates views/app_helpers/tbl'
  task :tbl do
    copy_resource :tbl, :views, 'app/views'
  end
  
  desc 'Updates views/app_helpers/template'
  task :template do
    copy_resource :template, :views, 'app/views'
  end
    
  def copy_resource(helper, type, location)
    location += "/app_helpers/#{helper}"
    if File.file? location
      puts "=> Removing old #{helper} #{type}..."
      system "rm -Rf #{location}"
    end
    puts "=> Copying #{type}..."
    system "mkdir -p #{location}"
    system "cp #{File.dirname(__FILE__)}/../resources/#{type}/#{helper} #{location}"
  end
end
