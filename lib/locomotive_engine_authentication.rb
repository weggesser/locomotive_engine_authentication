require           'locomotive_engine_authentication/version'
require           'locomotive/steam'
require_relative  'locomotive_engine_authentication/middlewares/register_liquid_middleware'

Locomotive::Steam.configure_extension do |config|
  config.middleware.insert_after Locomotive::Steam::Middlewares::TemplatizedPage, LocomotiveEngineAuthentication::Middlewares::RegisterLiquidMiddleware
end
