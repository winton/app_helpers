module AppHelpers
  
  def default_javascript
    "#{params[:controller]}/#{params[:action]}"
  end
  
  def default_stylesheet
    "#{params[:controller]}/#{params[:action]}"
  end
  
  def javascripts(*paths, &block)
    add_assets :javascripts, paths, &block
  end
  
  def stylesheets(*paths, &block)
    add_assets :stylesheets, paths, &block
  end
  
  def templates(*paths, &block)
    add_assets :templates, paths, &block
    nil
  end
  
private

  def add_assets(type, paths, &block)
    options = paths.extract_options!
    
    @assets ||= {}
    @assets[type] ||= []
    @layout_assets ||= {}
    @layout_assets[type] ||= []
    
    paths = nil if paths.empty?
    
    if options[:layout]
      options.delete :layout
      paths.push(options) if paths
      @layout_assets[type].push(paths          ) if paths
      @layout_assets[type].push(capture(&block)) if block
    else
      paths.push(options) if paths
      @assets[type].unshift(paths          ) if paths
      @assets[type].unshift(capture(&block)) if block
    end
    
    if !paths && !block
      logger.info 'LAYOUT'
      logger.info @layout_assets[type].inspect
      logger.info 'NON LAYOUT'
      logger.info @assets[type]
      
      @assets[type] = @layout_assets[type] + @assets[type]
      remove_dups @assets[type]
      @assets[type].collect do |item|
        if item.respond_to?(:pop)
          case type
          when :javascripts
            javascript_include_tag *item
          when :stylesheets
            stylesheet_link_tag *item
          when :templates
            paths.collect { |path| template item[0], item[1], item[2] }.join "\n"
          end + "\n"
        else
          case type
          when :javascripts
            "<script type='text/javascript'>\n#{item}\n</script>\n" unless item.blank?
          else
            item
          end
        end
      end
    end
  end

  def remove_dups(arr, list=[])
    arr.dup.each_index do |i|
      if arr[i].respond_to?(:pop)
        remove_dups arr[i], list
      else
        arr.delete_at(i) if list.include?(arr[i])
        list << arr[i]
      end
    end
  end
  
end