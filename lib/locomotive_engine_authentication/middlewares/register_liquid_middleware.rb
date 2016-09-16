require 'locomotive_engine_authentication/liquid/tags/authorized'

module LocomotiveEngineAuthentication
  module Middlewares
    class RegisterLiquidMiddleware
       
      def initialize app
         @app = app
      end
      
      def call env
        ::Liquid::Template.register_tag('authorized', LocomotiveEngineAuthentication::Liquid::Tags::Authorized)
        @app.call env
      end
      
    end
  end
end
