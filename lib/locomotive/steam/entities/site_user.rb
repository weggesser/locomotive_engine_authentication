require_dependency File.join Gem.loaded_specs['locomotivecms_steam'].full_gem_path, 'lib/locomotive/steam/models/entity'
require_relative  '../../../locomotive_engine_authentication/liquid/drops/site_user'

module Locomotive::Steam
  class SiteUser

    include ::Locomotive::Steam::Models::Entity

    def initialize(attributes)
      super({
        first_name:             nil,
        last_name:              nil,
        country:                nil,
        doccheck:               false,
        locked:                 true,
        email:                  nil,
        reset_password_token:   nil,
        password:               nil,
        password_confirmation:  nil,
        locale:                 nil,
        sex:                    nil,
        updated_at:             Time.zone.now
      }.merge(attributes))
    end

  
    def to_liquid
      ::LocomotiveEngineAuthentication::Liquid::Drops::SiteUser.new self
    end

  end
end
