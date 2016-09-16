module LocomotiveEngineAuthentication
  module Liquid
    module Tags
      class Authorized < ::Liquid::Tag
        def render(context)
          "This is authorized ..."
        end
      end
      ::Liquid::Template.register_tag('authorized', Authorized)
    end
  end
end
