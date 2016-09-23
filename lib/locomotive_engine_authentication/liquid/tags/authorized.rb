module LocomotiveEngineAuthentication
  module Liquid
    module Tags
      
      class Authorized < ::Liquid::Tag
        
        Syntax = /(#{::Liquid::VariableSignature}+)/o

        def initialize( tag_name, markup, options)
         if markup =~ Syntax
           @page = $1
         else
           raise ::Liquid::SyntaxError.new("Valid syntax: authorized [page]")
         end
         super
        end
        
        def render context
          request = context.registers[:request]
          # if @page.protected
          !request.session["current_user"].blank?
        end
        
      end
      
      ::Liquid::Template.register_tag( 'authorized'.freeze, Authorized )
      
    end
  end
end
