# frozen_string_literal: true

class PermalinksPresenter
  def initialize(path, message = nil)
    @path = path
    @message = message
  end

  def permalink
    "<p>#{link_message}: #{link_html}</p>"
  end

  def link_message
    return "Link to this page" unless @message
    @message
  end

  def link_html
    "<a href=\"#{url}\">#{url}</a>"
  end

  def url
    Rails.application.config.application_root_url + @path
  end
end
