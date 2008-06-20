module AppHelpers
  
  def default_javascript
    javascript_include_tag "#{params[:controller]}/#{params[:action]}"
  end
  
  def default_stylesheet
    stylesheet_link_tag "#{params[:controller]}/#{params[:action]}"
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
    @assets[type] ||= { :captures => [], :paths => [] }
    assets = @assets[type]
    paths  = nil if paths.empty?
    assets[:captures].push(capture(&block)) if block
    assets[:paths   ].push(paths)           if paths
    if !paths && !block
      remove_dups assets[:paths]
      [ assets[:paths].reverse.collect { |paths|
          case type
          when :javascripts
            javascript_include_tag *(paths + [ { :cache => true } ])
          when :stylesheets
            stylesheet_link_tag *(paths + [ { :cache => true } ])
          when :templates
            paths.collect { |path| template path[0], path[1], path[2] }.join "\n"
          end
        },
        assets[:captures].reverse
      ].flatten.join "\n"
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