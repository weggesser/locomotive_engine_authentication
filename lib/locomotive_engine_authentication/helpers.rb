require 'locomotive/steam/middlewares/helpers'

module LocomotiveEngineAuthentication::Helpers
  
  include ::Locomotive::Steam::Middlewares::Helpers
  
  def redirect_to_page handle, type=301
    target_page = services.page_finder.by_handle handle, false
    target_path = "/#{target_page.fullpath}"
    target_path = "/#{locale}#{target_path}" unless locale == default_locale
    redirect_to target_path, type
  end
  
end
