require 'locomotive/steam/middlewares/concerns/helpers'

module LocomotiveEngineAuthentication::Helpers

  include ::Locomotive::Steam::Middlewares::Concerns::Helpers

    def redirect_to_page handle, type=301
        target_page = services.page_finder.by_handle handle, false
        unless target_page.nil?
            target_path = "/#{target_page.fullpath}"
            target_path = "/#{locale}#{target_path}" unless locale == default_locale
            redirect_to target_path, type
        else
            raise "No site is set up with the handle '#{handle}'"
        end
    end

end
