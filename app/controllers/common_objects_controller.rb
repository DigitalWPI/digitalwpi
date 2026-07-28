class CommonObjectsController < ApplicationController
  def show
    curation_concern ||= Hyrax.query_service.find_by(id: params[:id])

    if curation_concern.class == Collection
      redirect_to Hyrax::Engine.routes.url_helpers.polymorphic_path(curation_concern)
    else
      redirect_to polymorphic_path(curation_concern)
    end
  rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
    render file: 'public/404.html', status: 404
  end
end
