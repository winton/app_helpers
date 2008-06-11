module AppHelpers
  
  def create_template(id, &block)
    block_to_partial 'app_helpers/template/textarea', { :id => id }, &block
  end
  
  def template(id, path=nil, locals={})
    create_template id.to_s do
      render :partial => (path.nil? ? params[:controller] + '/' + id.to_s : path), :locals => locals
    end
  end
  
end