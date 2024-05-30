# frozen_string_literal: true
class BookmarksController < CatalogController  
  include Blacklight::Bookmarks
  before_action :set_bookmark_category, only: [:index, :action_documents, :update_category_to_bookmark, :remove_category_from_bookmark, :generate_share_url, :delete_share_url, :delete_category]
  before_action :set_bookmarks, only: [:update_category_to_bookmark, :remove_category_from_bookmark]

  def index    
    @bookmarks = if @bookmark_category.present?
                    token_or_current_or_guest_user.categories.find_by(id: @bookmark_category.id).bookmarks
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
      bookmark_category = current_user.categories.create(title: params[:bookmark_category])
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
      @bookmark_category.bookmarks << @bookmarks
      render json: {massage: "Bookmark added in to Bookmark Category"}, status: 200
    else
      render json: {}, status: 442
    end
  end

  def remove_category_from_bookmark
    if @bookmark_category.present? && @bookmarks.present?
      @bookmark_category.bookmarks.delete(@bookmarks)
      render json: {massage: "Bookmark removed Bookmark Category"}, status: 200
    else
      render json: {}, status: 442
    end
  end

  def action_documents
    bookmarks = if params[:bookmark_category_id].present?
                    token_or_current_or_guest_user.categories.find_by(id: params[:bookmark_category_id]).bookmarks
                 else
                  token_or_current_or_guest_user.bookmarks
                 end
    bookmark_ids = bookmarks.collect { |b| b.document_id.to_s }
    fetch(bookmark_ids)
  end

  def generate_share_url
    if current_user.present?
      token = encrypt_user_id(current_user.id, @bookmark_category&.id)
      @bookmark_category.update(access_token: token)
    end

    redirect_to bookmarks_path(bookmark_category_id: @bookmark_category.id)
  end

  def delete_share_url
    if @bookmark_category.present?
      @bookmark_category.update(access_token: nil)
    end
    redirect_to bookmarks_path(bookmark_category_id: @bookmark_category.id)
  end

  def delete_category
    if @bookmark_category.present?
      @bookmark_category.destroy
    end
    redirect_to bookmarks_path
  end

  private

  def set_bookmarks
    @bookmarks = current_user.bookmarks.where(document_id: params[:bookmark_document_ids])
  end

  def set_bookmark_category
    begin
      if params[:encrypted_user_id].present?
        @bookmark_category = decrypt_bookmark_category(params[:encrypted_user_id])
      elsif current_user.present? && params[:bookmark_category_id].present?
        @bookmark_category = current_user.categories.find_by(id: params[:bookmark_category_id])
        if @bookmark_category.nil?
          flash[:error] = "Bookmark category doesn't exist"
          redirect_to bookmarks_path
        end
      end
    rescue Blacklight::Exceptions::ExpiredSessionToken => e
      flash[:error] = "The link you're trying to access has expired"
      redirect_to bookmarks_path
    end 
  end

  def secret_key_generator
    @secret_key_generator ||= begin
      app = Rails.application

      secret_key_base = if app.respond_to?(:credentials)
                          # Rails 5.2+
                          app.credentials.secret_key_base || app.secrets.secret_key_base
                        else
                          # Rails <= 5.1
                          app.secrets.secret_key_base
                        end
      ActiveSupport::KeyGenerator.new(secret_key_base)
    end
  end

  def encrypt_user_id(user_id, bookmark_category_id= nil, current_time = nil)
    current_time ||= Time.zone.now
    message_encryptor.encrypt_and_sign([user_id, current_time, bookmark_category_id])
  end

  # Used for #export action, with encrypted user_id.
  def decrypt_user_id(encrypted_user_id)
    user_id, timestamp, bookmark_category_id = message_encryptor.decrypt_and_verify(encrypted_user_id)

    user_id
  end

  def decrypt_bookmark_category(encrypted_user_id)
    user_id, timestamp, bookmark_category_id = message_encryptor.decrypt_and_verify(encrypted_user_id)

    user = User.find_by(id: user_id)
    category = user.categories.find_by(id: bookmark_category_id)

    if category.access_token != encrypted_user_id
      raise Blacklight::Exceptions::ExpiredSessionToken
    end

    category
  end
end 