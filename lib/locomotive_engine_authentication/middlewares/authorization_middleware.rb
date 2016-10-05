require 'locomotive/steam/middlewares/thread_safe'
require_relative  '../helpers'

module LocomotiveEngineAuthentication
  module Middlewares
    
    # Register Authorization Middleware
    class AuthorizationMiddleware < ::Locomotive::Steam::Middlewares::ThreadSafe
      
        include ::LocomotiveEngineAuthentication::Helpers

      def _call
        
        page    = env['steam.page']
        site    = env['steam.site']
        
        begin
          user = ::SiteUser.find( request.session[:current_site_user]['_id'] )
        rescue
          user = nil
        end
        
        # Do a redirect if user has no access
        if !page.nil? and page.protected and ::Locomotive::Steam.configuration.mode != :test
          if user.nil? or ( !user.nil? and !user.has_access_to?( site ) )
            redirect_to_page site.protected_register_page_handle, 302 # services.page_finder.by_handle site.protected_register_page_handle, false
          end
        end
        
      end

      
    end
    
  end
end
