module LocomotiveEngineAuthentication
  module Liquid
    module Tags
      
      class Authorized < ::Liquid::Tag
        
        Syntax = /(#{::Liquid::VariableSignature}+)/o

        def initialize( tag_name, markup, options)
         if markup =~ Syntax
           page = $1
         else
           raise ::Liquid::SyntaxError.new("Valid syntax: session_assign [var] = [source]")
         end
         super
        end
        
        def render context
          request = context.registers[:request]
          
          !request.session["authorized_user_id"].blank?
        end
        
      end
      
      ::Liquid::Template.register_tag( 'authorized'.freeze, Authorized )
      
    end
  end
end
