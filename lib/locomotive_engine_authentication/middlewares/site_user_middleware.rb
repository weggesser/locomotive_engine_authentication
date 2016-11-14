require 'locomotive/steam/middlewares/thread_safe'
require_relative  '../../locomotive/steam/entities/site_user'
require_relative  '../helpers'


module LocomotiveEngineAuthentication
  module Middlewares
    
    # Register Authorization Middleware
    class SiteUserMiddleware < ::Locomotive::Steam::Middlewares::ThreadSafe
      
      include ::LocomotiveEngineAuthentication::Helpers

      def _call
        
        env['steam.liquid_assigns'].merge!({ 'doc_check_token' => ENV['DOC_CHECK_TOKEN'] })
        # skip this when using wagon
        if ::Locomotive::Steam.configuration.mode != :test
          
          # if page.handle == site.protected_register_page_handle and request.session[:locked_site_user]
          #   site_user = ::SiteUser.find( request.session[:locked_site_user] )
          #   env['steam.liquid_assigns'].merge!({ 'locked_site_user' => site_user.to_liquid })
          #   request.session[:locked_site_user] = nil
          # end
          
          
          # REGISTRATION
          if page.handle == site.protected_register_page_handle and (!params[:site_user].blank? or !request.session[:doccheck_site_user].nil?)
            if !request.session[:doccheck_site_user].nil?
              site_user = ::SiteUser.new request.session[:doccheck_site_user]
              request.session[:doccheck_site_user] = nil
            else
              site_user = ::SiteUser.new params[:site_user]
              site_user.site_id = site._id
              site_user.doccheck = true if params[:site_user][:doccheck] == 'on'
              # site_user.save if site_user.valid?
            end
            site_user.email_confirmed_token = SecureRandom.uuid
            site_user.email_confirmed = false
            # TODO double check, if doccheck user should not need confirmation
            site_user.email_confirmed = true if site_user.doccheck
            site_user.validate
            if site_user.valid? and site_user.doccheck
              request.session[:doccheck_site_user] = params[:site_user]
              redirect_to_page site.protected_doccheck_page_handle , 302
            elsif site_user.valid? and !site_user.doccheck
              success = site_user.save
              if success
                env['steam.liquid_assigns'].merge!({ 'site_user_created' => true })
              else
                env['steam.liquid_assigns'].merge!({ 'site_user_created' => false })
              end
            end
            ::SiteUserMailer.email_confirmation( site_user ).deliver_now if site_user.valid?
            env['steam.liquid_assigns'].merge!({ 'site_user' => site_user.to_liquid })
          end
          
          # EMAIL CONFIRMATION
          if page.handle == site.request_email_confirmation_page_handle
            # TODO check if param equals the email of one user
            confirmation_site_user = ::SiteUser.find params[:site_user_id]
            if !confirmation_site_user.nil? and confirmation_site_user.email_confirmed_token == params[:confirmation_token]
              confirmation_site_user.email_confirmed = true
              confirmation_site_user.email_confirmed_token = nil
              success = confirmation_site_user.save
              if success
                env['steam.liquid_assigns'].merge!({ 'messages' => "sucess_email_confirm_message" })

                ::SiteUserMailer.new_registration( confirmation_site_user ).deliver_now
              else
                env['steam.liquid_assigns'].merge!({ 'messages' => "save_failure_email_confirm_message" })
              end
            else
              env['steam.liquid_assigns'].merge!({ 'messages' => "failure_email_reset_message" })
            end
          end
          
          # LOGIN
          if page.handle == site.protected_login_page_handle and !params[:site_user].blank?
            site_user = ::SiteUser.find_for_database_authentication({ email: params[:site_user][:email] })
            if !site_user.nil? and site_user.valid_password? params[:site_user][:password] and !site_user.locked
              if site_user.email_confirmed
                request.session[:current_site_user] = site_user
                env['steam.liquid_assigns'].merge!({ 'site_user' => site_user.to_liquid })
                redirect_to_page site.protected_default_page_handle , 302
              else
                env['steam.liquid_assigns'].merge!({ 'errors' => 'login_email_not_confirmed_error' })  
              end
            elsif !site_user.nil? and site_user.valid_password? params[:site_user][:password] and site_user.locked
              env['steam.liquid_assigns'].merge!({ 'errors' => 'login_locked_error' })
            else
              env['steam.liquid_assigns'].merge!({ 'errors' => 'login_error' })
            end
          end
          
          # REQUEST RESET PASSWORD
          if page.handle == site.request_reset_password_page_handle and !params[:email].blank?
            site_user = SiteUser.where( email: params[:email] ).first
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
              site_user = ::SiteUser.where({ reset_password_token: params[:token] }).first
            else
              begin
                site_user = ::SiteUser.find request.session[:current_site_user]["id"]
              rescue
                site_user = nil
              end
            end 
            
            # set action in order to set appropriate translation keys
            ( params[:token].blank? and site_user ) ? action = "change" : action = "reset"
            
            if site_user
              if params[:site_user] and site_user.update_attributes( params[:site_user] )
                env['steam.liquid_assigns'].merge!({ 'messages' => "#{action}_password_success_message" })
              end
              env['steam.liquid_assigns'].merge!({ 'site_user' => site_user.to_liquid })
            else
              env['steam.liquid_assigns'].merge!({ 'messages' => "#{action}_password_token_failure_message" })
            end
          end
          
          # update-account
          # Update
          if path == 'account' # and !params[:site_user].blank? and request.session[:current_site_user] != nil
            site_user = SiteUser.where({ id: request.session[:current_site_user]['id'] }).first
            env['steam.liquid_assigns'].merge!({ 'site_user' => site_user.to_liquid }) if site_user
            if site_user and !params[:site_user].blank? and request.session[:current_site_user] != nil
              if site_user.update_attributes( params[:site_user] )
                # What is that?
                request.session[:current_site_user] = site_user
                env['steam.liquid_assigns'].merge!({ 'messages' => 'update_account_success_message' })
              else
                env['steam.liquid_assigns'].merge!({ 'messages' => 'update_account_failure_message' })
              end
            end
          # Display Form
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
              site_user = ::SiteUser.new request.session[:doccheck_site_user] # ::SiteUser.find request.session[:doccheck_site_user]
              site_user.site_id = site._id
              site_user.doccheck = true
              site_user.locked = false
              success = site_user.save
              if success
                request.session[:current_site_user] = site_user
                request.session[:doccheck_site_user] = nil
                redirect_to_page site.protected_default_page_handle , 302
              else
                redirect_to_page site.protected_register_page_handle , 302
              end
            else
              request.session[:doccheck_site_user] = nil
              redirect_to_page site.protected_register_page_handle , 302
            end
          end
        
        else
          # WAGON HERE !!!
          if page.handle == 'login'  and !params[:site_user].blank?
            site_user = ::Locomotive::Steam::SiteUser.new({ first_name: 'Jane', last_name: 'Doe', title:'' })
            request.session[:current_site_user] = site_user
            env['steam.liquid_assigns'].merge!({ 'site_user' => site_user.to_liquid })
          end
          
          if path == 'logout'
            request.session[:current_site_user] = nil
            env['steam.liquid_assigns'].merge!({ 'site_user' => nil })
            redirect_to_page 'home' , 302
          end
          
        end
        
        
        
      end
      
    end
    
  end
end
