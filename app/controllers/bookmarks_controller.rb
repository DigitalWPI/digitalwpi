# frozen_string_literal: true
class BookmarksController < CatalogController  
  include Blacklight::Bookmarks
  before_action :set_bookmark_category, only: [:index, :update_category_to_bookmark]
  before_action :set_bookmarks, only: :update_category_to_bookmark

  def index
    @bookmarks = if params[:bookmark_category_id].present?
                    token_or_current_or_guest_user.bookmarks.where(bookmark_category_id: params[:bookmark_category_id])
                 else
                  token_or_current_or_guest_user.bookmarks
                 end
    bookmark_ids = @bookmarks.collect { |b| b.document_id.to_s }

    @response, @document_list = fetch(bookmark_ids)

    respond_to do |format|
      format.html { }
      format.rss  { render :layout => false }
      format.atom { render :layout => false }
      format.json do
        render json: render_search_results_as_json
      end

      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  def create_category
    if params[:bookmark_category].present?
      bookmark_category = BookmarkCategory.create(title: params[:bookmark_category])
      if bookmark_category.errors.present?
        flash[:error] = bookmark_category.errors.full_messages
        redirect_to bookmarks_path
      else
        flash[:notice] = "Bookmark Category Created Successfully" 
        redirect_to bookmarks_path
      end
    else
      flash[:error] = "bookmark_category: can't be blank" 
      redirect_to bookmarks_path
    end
  end

  def update_category_to_bookmark
    if @bookmark_category.present? && @bookmarks.present?
      @bookmarks.update_all(bookmark_category_id: @bookmark_category.id)
      render json: {massage: "Bookmark added in to Bookmark Category"}, status: 200
    else
      render json: {}, status: 442
    end
  end

  def action_documents
    bookmarks = if params[:bookmark_category_id].present?
                    token_or_current_or_guest_user.bookmarks.where(bookmark_category_id: params[:bookmark_category_id])
                 else
                  token_or_current_or_guest_user.bookmarks
                 end
    bookmark_ids = bookmarks.collect { |b| b.document_id.to_s }
    fetch(bookmark_ids)
  end


  private

  def set_bookmarks
    @bookmarks = current_user.bookmarks.where(document_id: params[:bookmark_document_ids])
  end

  def set_bookmark_category
    if params[:bookmark_category_id].present?
      @bookmark_category = BookmarkCategory.find_by(id: params[:bookmark_category_id])
    end
  end
end 