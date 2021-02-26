class PdfviewerController < ApplicationController
  layout "pdfviewer"
  def index
    @id = params[:id]
    @parent_id = FileSet.find(@id).parent_id
  end
end