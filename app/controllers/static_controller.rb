# frozen_string_literal: true

class StaticController < ApplicationController
  def login
    if current_user
      redirect_to Hyrax::Engine.routes.url_helpers.dashboard_path
    elsif AUTH_CONFIG['sso_enabled']
      render "static/login"
    else
      redirect_to new_user_session_path
    end
  end
  
  def infos
    render "static/about-page"
  end

  def helps
    render "static/help-page"
  end

  def centers
    render "static/project-centers"
  end

end
