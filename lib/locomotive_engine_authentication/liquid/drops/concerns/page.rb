module LocomotiveEngineAuthentication::Liquid::Drops::Concerns
  module Page 
  def accessible?
    # raise "X"
    session = @context.registers[:request].session
    site    = @context.registers[:site]
    user    = session[:current_site_user]
    page    = @_source
    
    begin
      user = ::SiteUser.find( session[:current_site_user]['_id'] )
    rescue
      user = nil
    end
    
    ::Locomotive::Steam.configuration.mode == :test or !@_source.protected or ( @_source.protected and !user.nil? and user.has_access_to? site )
    
  end
end
end
