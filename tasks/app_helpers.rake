desc 'Updates views/shared for all resources'
task :app_helpers => [ 'app_helpers:views' ]

namespace :app_helpers do
  desc 'Updates views/app_helpers'
  task :views do
    app_helper_resource :views, 'app/views'
  end
  
  desc 'Updates plugin resources from app'
  task :to_plugin do
    app_helper_resource :views, 'app/views', true
  end
    
  def app_helper_resource(type, location, reverse=false)
    from = "#{File.dirname(__FILE__)}/../resources/#{type}"
    to   = location + '/app_helpers'
    from, to = to, from if reverse
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
