module Hyrax
  module Renderers
    class SdgAttributeRenderer < AttributeRenderer
      include ::SdgService
      
      private
      
      def attribute_value_to_html(value)
        #SdgService.label(value)
        li_value(value)
      end

      def li_value(value)
        link_to(ERB::Util.h(SdgService.label(value)), search_path(value))
        #link_to(ERB::Util.h("test"), search_path(value))
      end

      def search_path(value)
        Rails.application.routes.url_helpers.search_catalog_path("f[#{search_field}][]": value, locale: I18n.locale)
      end

      def search_field
        ERB::Util.h(options.fetch(:search_field, field).to_s + "_sim")
      end

    end
  end
end