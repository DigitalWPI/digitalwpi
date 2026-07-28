module Hyrax
  module Renderers
    class SdgAttributeRenderer < AttributeRenderer
      include ::SdgService

      # Draw the table row for the attribute
      def render_sort
        return '' if values.blank? && !options[:include_empty]

        markup = %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)

        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")

        markup += Array(values).sort.map do |value|
          "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
        end.join

        markup += %(</ul></td></tr>)

        markup.html_safe
      end

      # Draw the dl row for the attribute
      def render_dl_row_sort
        return '' if values.blank? && !options[:include_empty]

        markup = %(<dt>#{label}</dt>\n<dd><ul class='tabular'>)

        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")

        markup += Array(values).sort.map do |value|
          "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
        end.join
        markup += %(</ul></dd>)

        markup.html_safe
      end

      private
      
      def attribute_value_to_html(value)
        li_value(value)
      end

      def li_value(value)
        link_to(ERB::Util.h(SdgService.label(value)), search_path(value))
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