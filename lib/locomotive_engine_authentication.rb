require           'locomotive/steam'
require_relative  'locomotive/steam/entities/page'
require_relative  'locomotive_engine_authentication/middlewares/register_liquid_middleware'
require_relative  'locomotive_engine_authentication/middlewares/authorization_middleware'
require_relative  'locomotive_engine_authentication/middlewares/site_user_middleware'
require_relative  'locomotive/steam/liquid/drops/page'

Locomotive::Steam.configure_extension do |config|
  unless config.middleware.index_of( LocomotiveEngineAuthentication::Middlewares::AuthorizationMiddleware ) == 0
    config.middleware.insert_after Locomotive::Steam::Middlewares::Page, LocomotiveEngineAuthentication::Middlewares::AuthorizationMiddleware
    config.middleware.insert_after Locomotive::Steam::Middlewares::Page, LocomotiveEngineAuthentication::Middlewares::SiteUserMiddleware
    config.middleware.insert_after Locomotive::Steam::Middlewares::TemplatizedPage, LocomotiveEngineAuthentication::Middlewares::RegisterLiquidMiddleware
  end
end
