module AppHelpers
  
  def widget(*lineage)
    options  = lineage.extract_options!
    unless w = widget_instance(lineage)
      w = Widget.new controller, logger, lineage, options
      widget_instance lineage, w
    end
    javascripts *w.assets[:javascripts] do
      w.render_init(:js) unless options[:dependencies_only]
    end
    stylesheets *w.assets[:stylesheets]
    templates *(w.assets[:templates].collect do |t|
      [ File.basename(t), t, w.options_for_render(w.options) ]
    end)
    if options[:dependencies_only]
      nil
    elsif options[:render_js]
      w.render_init(:partials) + "\n<script type='text/javascript'>\n#{w.render_init :js}\n</script>"
    else
      w.render_init :partials
    end
  end
  
  def widget_image(*lineage)
    options = lineage.extract_options!
    image   = lineage.pop
    image_tag "#{lineage.join('_')}/#{image}", options
  end
  
  def widget_partial(*lineage)
    options = lineage.extract_options!
    partial = lineage.pop
    if w = widget_instance(lineage)
      options[:locals] ||= {}
      options[:locals].merge! w.options_for_render
    end
    render options.merge(:partial => "#{lineage.join('/widgets/')}/partials/#{partial}")
  end
  
  private
  
  def widget_instance(lineage, value=nil)
    eval "@widget_#{lineage.join('_')}#{value ? " = value" : ''}"
  end
  
  class Widget
    attr :assets,     true
    attr :lineage,    true
    attr :logger,     true
    attr :options,    true
    attr :options_rb, true
    
    def initialize(controller, logger, lineage, options)
      @controller = controller
      @logger  = logger
      @options = options
      @lineage = lineage
      
      return if lineage.empty?
      
      @options_rb = options_rb
      @assets = {
        :images => [], :javascripts => [], :stylesheets => [], :templates => [], :init_js => [], :init_partials => []
      }
      
      update_asset_partials :init_js
      update_asset_partials :init_partials
      update_asset_partials :templates
      update_assets :images
      update_assets :javascripts
      update_assets :stylesheets
    end
    
    def options_for_render(merge_with={})
      opts = @options_rb.merge merge_with
      opts.merge(:options => opts)
    end
    
    def render_init(type)
      @assets["init_#{type}".intern].collect do |f|
        @controller.render_to_string :file => f, :locals => options_for_render(@options)
      end.join("\n")
    end
    
    def to_path(type, index=0)
      lineage = @lineage[0..index]
      asset   = @lineage.join('_')
      base    = 'app/widgets/' + lineage.join('/widgets/')
      case type
      when :base:          base
      when :asset:         asset
      when :options:       base + '/options.rb'
      when :init_js:       base + '/javascripts/init'
      when :init_partials: base + '/partials/_init'
      when :templates:     base + '/templates'
      when :images:      [ base + '/images',      'public/images/widgets/'      + asset ]
      when :javascripts: [ base + '/javascripts', 'public/javascripts/widgets/' + asset ]
      when :stylesheets: [ base + '/stylesheets', 'public/stylesheets/widgets/' + asset ]
      end
    end
    
  private
  
    def filename_to_partial(f, remove=nil)
      base = File.basename f
      dir  = File.dirname f
      f    = [ dir, (base[0..0] == '_' ? base[1..-1] : base ).split('.')[0] ].join '/'
      if remove
        if remove.respond_to?(:pop)
          remove.each { |r| f.gsub! r, '' }
        else
          f.gsub! remove, ''
        end
      end
      f
    end
    
    def update_asset_partials(type, index=0)
      return if index >= @lineage.length
      from = to_path type, index
      from = File.directory?(from) ? "#{from}/*" : "#{from}.*"
      Dir[from].each do |f|
        @assets[type] << (type == :templates ? filename_to_partial(f, 'app/widgets/') : f)
      end
      update_asset_partials type, index+1
    end
    
    def options_rb(index=0, options={})
      return options if index >= @lineage.length
      path = to_path :options, index
      options.merge!(eval(File.read(path))) if File.exists?(path)
      options_rb index + 1, options
    end
    
    def needs_update?(from, to)
      File.exists?(to) ? File.mtime(from) > File.mtime(to) : true
    end
    
    def update_assets(type, index=0)
      return @assets[type] if index >= @lineage.length
      @assets[type] += update_directory(*(to_path(type, index) + [ index, type ]))
      update_assets type, index + 1
    end
    
    def update_directory(from, to, index, type)
      Dir["#{from}/*"].collect do |f|
        next if f.include?('/init.js')
        t = to + f[from.length..-1]
        if File.directory?(f)
          update_directory f, t, index, type
        else
          t.gsub!('/widgets/', '/sass/widgets/') if f.include?('.sass')
          if to && needs_update?(f, t)
            FileUtils.mkdir_p File.dirname(t)
            if type == :images
              FileUtils.copy f, t
            else
              File.open t, 'w' do |file|
                file.write @controller.render_to_string(:file => f, :locals => options_for_render)
              end
            end
          end
          filename_to_partial t, [ "public/#{type}/", 'sass/' ]
        end
      end.compact.flatten
    end
  end
  
end