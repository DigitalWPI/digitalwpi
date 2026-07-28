class NestedNoteAttributeRenderer < NestedAttributeRenderer
  def attribute_value_to_html(input_value)
    html = ''
    return html if input_value.blank?
    value = parse_value(input_value)
    value.each do |v|
      each_html = ''
      unless v.dig('note').blank?
        label = 'Note'
        val = v['note']
        each_html += get_row(label, val)
      end
      unless v.dig('created').blank?
        label = 'Created'
        val = v['created']
        if v['created'].present?
          begin
            # val = Date.parse(v['created']).to_formatted_s(:standard)
            val = Date.parse(v['created']).to_formatted_s(:db)
          rescue ArgumentError
            val = v['created']
          end
        end
        each_html += get_row(label, val)
      end
      unless v.dig('user_name').blank?
        label = 'User'
        val = v['user_name']
        if v.dig('user_id').present?
          val = link_to(ERB::Util.h(v['user_id']), Hyrax::Engine.routes.url_helpers.user_path(v['user_id']))
        end
        each_html += get_row(label, val)
      end
      html += get_inner_html(each_html)
    end
    html_out = get_ouput_html(html)
    %(#{html_out})
  end
end
