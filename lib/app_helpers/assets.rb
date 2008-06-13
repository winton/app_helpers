module AppHelpers
  
  def javascripts(*scripts, &block)
    @javascripts ||= { :captures => [], :scripts => [] }
    @javascripts[:captures].push(capture(&block)) if block
    @javascripts[:scripts ].push(scripts)         unless scripts.empty?
    if !scripts && !block
      [ @javascripts[:scripts ].reverse.collect { |scripts| javascript_include_tag *(scripts + [ { :cache => true } ]) },
        @javascripts[:captures].reverse
      ].flatten.join "\n"
    end
  end
  
  def stylesheets(*sheets, &block)
    @stylesheets ||= { :captures => [], :sheets => [] }
    @stylesheets[:captures].push(capture(&block)) if block
    @stylesheets[:sheets  ].push(sheets)          unless sheets.empty?
    if !sheets && !block
      [ @stylesheets[:sheets  ].reverse.collect { |sheets| stylesheet_link_tag *(sheets + [ { :cache => true } ]) },
        @stylesheets[:captures].reverse
      ].flatten.join "\n"
    end
  end
  
  def default_javascript
    javascript_include_tag "#{params[:controller]}/#{params[:action]}"
  end
  
  def default_stylesheet
    stylesheet_link_tag "#{params[:controller]}/#{params[:action]}"
  end
  
end