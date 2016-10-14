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
            site_user.doccheck = true if params[:site_user][:doccheck] == 'on'
            site_user.save if site_user.valid?
            
            ::Rails.logger.warn "---------> NEW REGISTRATION WITH #{site_user.email} - #{site_user.valid?}"
            
            if site_user.valid? and site_user.doccheck
              request.session[:doccheck_site_user] = site_user.id
              redirect_to_page site.protected_doccheck_page_handle , 302
            elsif site_user.valid? and !site_user.doccheck
              ::SiteUserMailer.new_registration( site_user ).deliver_now
            end
            env['steam.liquid_assigns'].merge!({ 'site_user' => site_user.to_liquid })
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
          
          # REQUEST RESET PASSWORD
          if page.handle == site.request_reset_password_page_handle and !params[:email].blank?
            site_user = SiteUser.find_by email: params[:email]
            if site_user
              raw, enc = Devise.token_generator.generate(::SiteUser, :reset_password_token)
              site_user.reset_password_token   = enc
              site_user.reset_password_sent_at = Time.now.utc
              site_user.save( validate: false )
              site_user.save
              ::SiteUserMailer.reset_password( site_user ).deliver_now
              # Rails.logger.info "--------------------------------------------> "
              env['steam.liquid_assigns'].merge!({ 'messages' => 'request_reset_password_success_message' })
            else
              env['steam.liquid_assigns'].merge!({ 'messages' => 'request_reset_password_failure_message' })
            end
          end
          
          
          # RESET PASSWORD
          if page.handle == site.reset_password_page_handle
            unless params[:token].blank?
              site_user = SiteUser.where({ reset_password_token: params[:token] }).first
            end          
            if site_user
              if params[:site_user] and site_user.update_attributes( params[:site_user] )
                env['steam.liquid_assigns'].merge!({ 'messages' => 'reset_password_success_message' })
              end
              env['steam.liquid_assigns'].merge!({ 'site_user' => site_user.to_liquid })
            else
              env['steam.liquid_assigns'].merge!({ 'messages' => 'reset_password_token_failure_message' })
            end
          end
            
          
          
          # LOGOUT
          if path == 'logout'
            request.session[:current_site_user] = nil
            env['steam.liquid_assigns'].merge!({ 'site_user' => nil })
            redirect_to_page site.protected_default_page_handle , 302
          end
          
          # DOCCHECK
          if path == 'doccheck-return'
            if !request.session[:doccheck_site_user].blank?
              site_user = ::SiteUser.find request.session[:doccheck_site_user]
              site_user.locked = false
              site_user.save
              request.session[:current_site_user] = site_user
              request.session[:doccheck_site_user] = nil
              redirect_to_page site.protected_default_page_handle , 302
            else
              request.session[:doccheck_site_user] = nil
              redirect_to_page site.protected_register_page_handle , 302
            end
          end
        
        end
        
        
        
      end
      
    end
    
  end
end
