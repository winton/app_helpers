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
    @assets ||= {}
    @assets[type] ||= []
    
    paths = nil if paths.empty?
    @assets[type].push(capture(&block)) if block
    @assets[type].push(paths          ) if paths
    
    if !paths && !block
      remove_dups @assets[type]
      @assets[type].reverse.collect do |item|
        if item.respond_to?(:pop)
          case type
          when :javascripts
            javascript_include_tag *(item + [ { :cache => true } ])
          when :stylesheets
            stylesheet_link_tag    *(item + [ { :cache => true } ])
          when :templates
            paths.collect { |path| template item[0], item[1], item[2] }.join "\n"
          end + "\n"
        else
          case type
          when :javascripts
            "<script type='text/javascript'>\n#{item}\n</script>\n"
          else
            item
          end
        end
      end
    end
  end

  def remove_dups(arr, list=[])
    arr.each do |a|
      if a.respond_to?(:pop)
        remove_dups a, list
      elsif list.include?(a)
        a.delete a
      else
        list << a
      end
    end
  end
  
end