module Hyrax
  module Renderers
    class SdgAttributeRenderer < AttributeRenderer
      include ::SdgService
      
      private
      
      def attribute_value_to_html(value)
        SdgService.label(value)
      end
    end
  end
end