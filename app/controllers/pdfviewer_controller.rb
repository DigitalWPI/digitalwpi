class PdfviewerController < ApplicationController
  layout "pdfviewer"

  def index
    if FileSet.exists?(params[:id])
      @id = params[:id]
      @parent_id = FileSet.find(@id).parent_id
    else
      redirect_to root_path, alert: "Document not found"
    end
  end
end