class PdfviewerController < ApplicationController
  layout "pdfviewer"

  def index
    if FileSet.exists?(params[:id])
      @id = params[:id]
      file = FileSet.find(@id)
      if not current_user.nil?
        if current_user.ability.can?(:show, file)
          @parent_id = file.parent_id
        else
          redirect_to "/show/#{file.parent_id}", alert: "You are not authorized to access this page."
        end
      elsif FileSet.find(@id).public?
        @parent_id = file.parent_id
      else
        redirect_to "/login", alert: "You are not authorized to access this page."
      end
    else
      redirect_to root_path, alert: "Document not found"
    end
  end
end
