desc 'Updates views/shared for all resources'
task :app_helpers => [ 'app_helpers:tbl', 'app_helpers:template' ]

namespace :app_helpers do  
  desc 'Updates views/app_helpers/tbl'
  task :tbl do
    helper_resource :views, :tbl, 'app/views'
  end
  
  desc 'Updates views/app_helpers/template'
  task :template do
    helper_resource :views, :template, 'app/views'
  end
  
  def helper_resource(type, helper, location)
    from = "#{File.dirname(__FILE__)}/../resources/#{type}/#{helper}"
    to   = location + "/app_helpers/#{helper}"
    puts "=> Removing old #{type}..."
    FileUtils.remove_dir to, true
    FileUtils.mkdir_p to
    puts "=> Copying #{type}..."
    Dir["#{from}/*"].each do |f|
      if File.directory? f
        FileUtils.mkdir_p "#{to}/#{File.basename(f)}"
        FileUtils.cp_r f, to
      else
        FileUtils.cp f, to
      end
    end
  end
end
