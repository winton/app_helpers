module AppHelpers
  
  def javascripts(&block)
    if block
      @javascripts ||= []
      @javascripts  << capture(&block)
    end
    @javascripts ? @javascripts.reverse.join("\n") : nil
  end
  
  def stylesheets(&block)
    if block
      @stylesheets ||= []
      @stylesheets  << capture(&block)
    end
    @stylesheets ? @stylesheets.reverse.join("\n") : nil
  end
  
  def default_javascript
    javascript_include_tag "#{params[:controller]}/#{params[:action]}"
  end
  
  def default_stylesheet
    stylesheet_link_tag "#{params[:controller]}/#{params[:action]}"
  end
  
end