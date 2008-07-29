module AppHelpers
  
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => block ? capture(&block) : '')
    concat(render(:partial => partial_name, :locals => options), block ? block.binding : nil)
  end
  
  def script_tag_redirect_to(url)
    render :partial => 'app_helpers/script_tag', :locals => { :body => "window.location = '#{url}';" }
  end
  
end