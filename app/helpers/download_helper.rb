module DownloadHelper
  HEADER_FIELDS = %w(id has_model_ssim title_tesim creator_tesim identifier_tesim
                     description_tesim contributor_tesim advisor_tesim committee_tesim
                     keyword_tesim publisher_tesim subject_tesim resource_type_tesim
                     degree_tesim department_tesim year_tesim rights_statement_tesim
                     license_tesim sponsor_tesim orcid_tesim date_created_tesim award_tesim
                     center_tesim sdg_tesim major_tesim).freeze

  def search_documents
    page = 1
    total_pages = Float::INFINITY

    CSV.generate(headers: true) do |csv|
      csv << generate_csv_header
      
      while page <= total_pages
        params[:page] = page
        params[:per_page] = 5000
        (@response, @document_list) = search_results(params)

        # Add rows to CSV
        generate_csv_rows(@document_list).each do |row|
          csv << row
        end

        total_pages = @response.total_pages if page == 1
        page += 1
      end
    end
  end

  def build_csv_for_bookmarks(document_list)
    CSV.generate(headers: true) do |csv|
      csv << generate_csv_header
      generate_csv_rows(@document_list).each do |row|
        csv << row
      end
    end
  end

  private

  def generate_csv_header
    HEADER_FIELDS.map { |field| I18n.t("hyrax.downloads.csv_header.fields.#{field}") }
  end

  def generate_csv_rows(document_list)
    document_list.map do |list|
      data = list._source
      HEADER_FIELDS.map do |field|
        if data[field].present?
          if data[field].is_a?(Array)
            data[field].join(";")
          elsif field == "id"
            PermalinksPresenter.new("/show/#{data[field]}").url
          else
            data[field]
          end
        else
          ''
        end
      end
    end
  end
end
