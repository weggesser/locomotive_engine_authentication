module LocomotiveEngineAuthentication::Liquid::Drops::Concerns
  module Page 
    def accessible?
      
      session = @context.registers[:request].session
      site    = @context.registers[:site]
      user    = session[:current_site_user]
      page    = @_source
      
      begin
        unless ::Locomotive::Steam.configuration.mode == :test
          user = ::SiteUser.find( session[:current_site_user]['_id'] )
        else
          user = session[:current_site_user]
        end
      rescue
        user = nil
      end
      
      !@_source.protected or ( @_source.protected and !user.nil? and user.has_access_to? site )
    end
    
    def protected?
      @_source.protected
    end
    
  end
end
