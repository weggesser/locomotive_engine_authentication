require 'locomotive/steam/middlewares/thread_safe'
require 'locomotive/steam/middlewares/helpers'

module LocomotiveEngineAuthentication
  module Middlewares
    
    # Register Authorization Middleware
    class AuthorizationMiddleware < ::Locomotive::Steam::Middlewares::ThreadSafe
      
      include ::Locomotive::Steam::Middlewares::Helpers

      def _call
        
      end

      
    end
    
  end
end
