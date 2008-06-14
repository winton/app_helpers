module AppHelpers
  
  def widget(*args)
    options = args.extract_options!
    return if args.empty?
    
    js   = []
    css  = []
    sass = []
    
    while args.length > 0
      paths   = widget_paths args.join('/widgets/')
      options = options.merge eval(File.read(paths[:def]))
      
      js   << update_directory(paths, options, :js)
      css  << update_directory(paths, options, :css)
      sass << update_directory(paths, options, :sass)
      
      args.pop
    end
    
    # See assets.rb
    javascripts *js.flatten
    stylesheets *(css.flatten + sass.flatten)
  end
  
  def widget_partial(*args)
    path = args.join('/widgets/')
  end

private
  
  def update_directory(paths, options, type)
    path_from = paths[type]
    path_to   = paths[:copy_to][type]
    
    erb  = Dir["#{path_from}/*.#{type}.erb"].collect
    from = Dir["#{path_from}/*.#{type}"].collect
    to   = Dir["#{path_to}/*.#{type}"  ].collect
    
    base_erb  = erb.collect  { |f| File.basename f, '.erb' }
    base_from = from.collect { |f| File.basename f }
    base_to   = to.collect   { |f| File.basename f }
    
    # Delete files removed from widget
    (base_to - base_from - base_erb).each do |f|
      File.delete [ path_to, f ].join('/')
    end
    
    # Copy non-ERB files
    assets = from.collect do |f|
      t = [ path_to, File.basename(f) ].join '/'
      if needs_update?(f, t)
        system "mkdir -p #{File.dirname t}"
        system "cp -f #{f} #{t}"
      end
      [ paths[:asset], File.basename(f, ".#{type}") ].join '/'
    end
    
    # Copy ERB files
    assets + erb.collect do |f|
      t = [ path_to, File.basename(f, '.erb') ].join '/'
      if needs_update?(f, t)
        system "mkdir -p #{File.dirname t}"
        File.open t, 'w' do |file|
          file.write ERB.new(File.read(f)).result(options_binding(options))
        end
      end
      [ paths[:asset], File.basename(f, ".#{type}.erb") ].join '/'
    end
  end
  
  def options_binding(options)
    evals = ''
    pairs = options.to_a
    pairs.each_index { |i| evals += "#{pairs[i][0]} = pairs[#{i}][1];" }
    eval evals
    binding
  end
  
  def needs_update?(from, to)
    File.exists?(to) ? File.mtime(from) > File.mtime(to) : true
  end

  def widget_paths(path)
    base  = "app/widgets/#{path}"
    asset = "#{path.gsub '/widgets', ''}"
    {
      :def   => "#{base}/options.rb",
      :js    => "#{base}/javascripts",
      :css   => "#{base}/stylesheets",
      :sass  => "#{base}/stylesheets",
      :asset => "widgets/#{asset}",
      :copy_to => {
        :js   => "public/javascripts/widgets/#{asset}",
        :css  => "public/stylesheets/widgets/#{asset}",
        :sass => "public/stylesheets/sass/widgets/#{asset}"
      },
    }
  end
  
end