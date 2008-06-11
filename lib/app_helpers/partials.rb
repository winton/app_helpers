module AppHelpers
  
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => block ? capture(&block) : '')
    concat(render(:partial => partial_name, :locals => options), block ? block.binding : nil)
  end
  
end