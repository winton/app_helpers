module AppHelpers
  
  def widget(*args)
    options = args.extract_options!
    return if args.empty?
    
    js   = []
    css  = []
    sass = []
    
    while args.length > 0
      paths   = widget_paths args.join('/widgets/')
      options = eval(File.read(paths[:def])).merge options
      
      js   << update_directory(paths, :js)
      css  << update_directory(paths, :css)
      sass << update_directory(paths, :sass)
      
      args.pop
    end
    
    js.flatten.inspect
  end

private
  
  def update_directory(paths, type)
    path_from = paths[type]
    path_to   = paths[:copy_to][type].gsub '/widgets', ''
    
    from = Dir["#{path_from}/*.#{type}"].collect
    to   = Dir["#{path_to}/*.#{type}"  ].collect
    
    base_from = from.collect { |f| File.basename f }
    base_to   = to.collect   { |f| File.basename f }
    
    # Delete files removed from widget
    (base_to - base_from).each_index do |f|
      logger.info 'DELETE ' + [ path_to, f ].join('/')
      #File.delete [ path_to, f ].join('/')
    end
    
    from.collect do |f|
      t = [ path_to, File.basename(f) ].join '/'
      logger.info 'COPY ' + "#{f} #{t}"  if needs_update?(f, t)
      #system("cp -f #{f} #{t}") if needs_update?(f, t)
      [ paths[:asset], File.basename(f, ".#{type}") ].join '/'
    end
  end
  
  def needs_update?(from, to)
    if !File.exists?(to)
      true
    else
      File.mtime(from) > File.mtime(to)
    end
  end

  def widget_paths(path)
    base  = "app/widgets/#{path}"
    asset = "#{path.gsub '/widgets', ''}"
    {
      :def   => "#{base}/widget.rb",
      :js    => "#{base}/javascripts",
      :css   => "#{base}/stylesheets",
      :sass  => "#{base}/stylesheets/sass",
      :asset => "widgets/#{asset}",
      :copy_to => {
        :js   => "public/javascripts/widgets/#{asset}",
        :css  => "public/stylesheets/widgets/#{asset}",
        :sass => "public/stylesheets/sass/widgets/#{asset}"
      },
    }
  end
  
end