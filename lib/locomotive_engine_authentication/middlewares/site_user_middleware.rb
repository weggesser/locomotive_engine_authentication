require 'locomotive/steam/middlewares/thread_safe'
require_relative  '../../locomotive/steam/entities/site_user'
require_relative  '../helpers'


module LocomotiveEngineAuthentication
  module Middlewares
    
    # Register Authorization Middleware
    class SiteUserMiddleware < ::Locomotive::Steam::Middlewares::ThreadSafe
      
      include ::LocomotiveEngineAuthentication::Helpers

      def _call
        
        if ::Locomotive::Steam.configuration.mode != :test
          # REGISTRATION
          if page.handle == site.protected_register_page_handle and !params[:site_user].blank?
            site_user = ::SiteUser.new params[:site_user]  
            site_user.site_id = site._id
            site_user.save
            env['steam.liquid_assigns'].merge!({ 'site_user' => site_user.to_liquid })
            # raise "X"
          end
          
          # LOGIN
          if page.handle == site.protected_login_page_handle and !params[:site_user].blank?
            site_user = ::SiteUser.find_for_database_authentication({ email: params[:site_user][:email] })
            if !site_user.nil? and site_user.valid_password? params[:site_user][:password] and !site_user.locked
              request.session[:current_site_user] = site_user
              env['steam.liquid_assigns'].merge!({ 'site_user' => site_user.to_liquid })
              redirect_to_page site.protected_default_page_handle , 302          
            elsif !site_user.nil? and site_user.valid_password? params[:site_user][:password] and site_user.locked
              env['steam.liquid_assigns'].merge!({ 'errors' => 'login_locked_error' })
            else
              env['steam.liquid_assigns'].merge!({ 'errors' => 'login_error' })
            end
          end
          
          # LOGOUT
          if path == 'logout'
            request.session[:current_site_user] = nil
            env['steam.liquid_assigns'].merge!({ 'site_user' => nil })
            redirect_to '/' , 302   
          end
        
        end
        
        
        
      end
      
    end
    
  end
end
