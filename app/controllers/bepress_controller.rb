class BepressController < ApplicationController

  def record
    @record = Bepress.where({:resource_type => params[:resource_type], :bepress_id => params[:bepress_id]}).first
    if @record
      if @record.hyrax_id
        @url = "/show/" + @record.hyrax_id
      else
        @url = "/collections/" + @record.resource_type
      end
    else
      @url = "/collections/" + params[:resource_type]
    end
    redirect_to @url
  end

  def document
    @record = Bepress.where({:resource_type => params[:resource_type], :document_id => params[:download_id]}).first
    if @record
      if @record.hyrax_id
        @url = "/show/" + @record.hyrax_id
      else
        @url = "/collections/" + @record.resource_type
      end
    else
      @url = "/collections/" + params[:resource_type]
    end
    redirect_to @url
  end

end
