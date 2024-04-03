# frozen_string_literal: true
require 'csv'
class CatalogController < ApplicationController

  include BlacklightRangeLimit::ControllerOverride
  include BlacklightAdvancedSearch::Controller
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior
  include BlacklightOaiProvider::Controller

  # This filter applies the hydra access controls
  before_action :enforce_show_permissions, only: :show
  # Allow all search options when in read-only mode
  # skip_before_action :check_read_only

  def self.uploaded_field
    solr_name('system_create', :stored_sortable, type: :date)
  end

  def self.created_field
    solr_name('date_created', :stored_sortable, type: :date)
  end

  def self.modified_field
    solr_name('system_modified', :stored_sortable, type: :date)
  end

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'all_fields'
    config.advanced_search[:query_parser] ||= 'dismax'

    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    config.search_builder_class = Hyrax::CatalogSearchBuilder

    # Show gallery view
    config.view.gallery.partials = [:index_header, :index]
    config.view.slideshow.partials = [:index]

    # Because too many times on Samvera tech people raise a problem regarding a failed query to SOLR.
    # Often, it's because they inadvertently exceeded the character limit of a GET request.
    config.http_method = :post

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: "search",
      rows: 10,
      qf: "title_tesim description_tesim creator_tesim keyword_tesim"
    }

    # solr field configuration for document/show views
    config.index.title_field = solr_name("title", :stored_searchable)
    config.index.display_type_field = solr_name("has_model", :symbol)
    config.index.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    # config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type", limit: 5
    config.add_facet_field solr_name('member_of_collection_ids', :symbol), label: 'Collections', sort: 'count', collapse: false, helper_method: :collection_title_by_id, limit: 5
    #config.add_facet_field solr_name("member_of_collections", :symbol), limit: 5, label: 'Collections', collapse: false
    #config.add_facet_field solr_name("year", :facetable), label: "Year", sort: 'index desc', limit: 5
    config.add_facet_field solr_name("year", :facetable), label: "Year", range: {
     num_segments: 6,
     assumed_boundaries: [1350, Time.now.year+2],
     segments: true,
     maxlength: 10
    }, include_in_advanced_search: false
    config.add_facet_field solr_name("creator", :facetable), sort: 'index', index_range: 'A'..'Z', limit: 5, include_in_advanced_search: false
    config.add_facet_field solr_name("advisor", :facetable), label: "Advisor", sort: 'index', index_range: 'A'..'Z', limit: 5
    config.add_facet_field solr_name("contributor", :facetable), label: "Contributor", sort: 'index', index_range: 'A'..'Z', limit: 5, include_in_advanced_search: false
    config.add_facet_field solr_name("center", :facetable), label: "Project Center", sort: 'index', index_range: 'A'..'Z', limit: 5
    config.add_facet_field solr_name("major", :facetable), label: "Major", sort: 'index', index_range: 'A'..'Z', limit: 5
    config.add_facet_field solr_name("department", :facetable), label: "Unit (Department)", sort: 'index', index_range: 'A'..'Z', limit: 5
    config.add_facet_field solr_name("publisher", :facetable), limit: 5, include_in_advanced_search: false
    config.add_facet_field solr_name("subject", :facetable), sort: 'index', index_range: 'A'..'Z', limit: 5, include_in_advanced_search: false
    config.add_facet_field solr_name('sdg', :facetable), label: "UN SDG", limit: 17, sort: 'index', helper_method: :sdg_facet_display
    config.add_facet_field solr_name("resource_type", :facetable), label: "Resource Type", limit: 5
    config.add_facet_field solr_name("license", :facetable), label: "License", limit: 5
    config.add_facet_field solr_name("award", :facetable), label: "Award", limit: 5
    # Removing sponsor facet, as the values are not controlled -
    # https://github.com/antleaf/wpi-repository-project/issues/69#issuecomment-1746994760
    # config.add_facet_field solr_name("sponsor", :facetable), label: "Sponsor", sort: 'index', index_range: 'A'..'Z', limit: 5
    #config.add_facet_field solr_name("language", :facetable), limit: 5


    # The generic_type isn't displayed on the facet list
    # It's used to give a label to the filter that comes from the user profile
    config.add_facet_field solr_name("generic_type", :facetable), if: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    # config.add_index_field solr_name("description", :stored_searchable), itemprop: 'description', helper_method: :iconify_auto_link
    config.add_index_field solr_name("keyword", :stored_searchable), itemprop: 'keywords', link_to_search: solr_name("keyword", :facetable)
    # config.add_index_field solr_name("subject", :stored_searchable), itemprop: 'about', link_to_search: solr_name("subject", :facetable)
    config.add_index_field solr_name("creator", :stored_searchable), itemprop: 'creator', link_to_search: solr_name("creator", :facetable)
    # config.add_index_field solr_name("contributor", :stored_searchable), itemprop: 'contributor', link_to_search: solr_name("contributor", :facetable)
    config.add_index_field solr_name("advisor", :stored_searchable), label: "Advisor", itemprop: 'advisor', link_to_search: solr_name("advisor", :facetable)
    # config.add_index_field solr_name("proxy_depositor", :symbol), label: "Depositor", helper_method: :link_to_profile
    # config.add_index_field solr_name("depositor"), label: "Owner", helper_method: :link_to_profile
    config.add_index_field solr_name("publisher", :stored_searchable), itemprop: 'publisher', link_to_search: solr_name("publisher", :facetable)
    # config.add_index_field solr_name("based_near_label", :stored_searchable), itemprop: 'contentLocation', link_to_search: solr_name("based_near_label", :facetable)
    # config.add_index_field solr_name("language", :stored_searchable), itemprop: 'inLanguage', link_to_search: solr_name("language", :facetable)
    # config.add_index_field solr_name("date_uploaded", :stored_sortable, type: :date), itemprop: 'datePublished', helper_method: :human_readable_date
    # config.add_index_field solr_name("date_modified", :stored_sortable, type: :date), itemprop: 'dateModified', helper_method: :human_readable_date
    config.add_index_field solr_name("date_created", :stored_searchable), itemprop: 'dateCreated', include_in_advanced_search: false
    # config.add_index_field solr_name("rights_statement", :stored_searchable), helper_method: :rights_statement_links
    # config.add_index_field solr_name("license", :stored_searchable), helper_method: :license_links
    config.add_index_field solr_name("resource_type", :stored_searchable), label: "Resource Type", link_to_search: solr_name("resource_type", :facetable)
    # config.add_index_field solr_name("file_format", :stored_searchable), link_to_search: solr_name("file_format", :facetable)
    # config.add_index_field solr_name("identifier", :stored_searchable), helper_method: :index_field_link, field_name: 'identifier'
    # config.add_index_field solr_name("embargo_release_date", :stored_sortable, type: :date), label: "Embargo release date", helper_method: :human_readable_date
    # config.add_index_field solr_name("lease_expiration_date", :stored_sortable, type: :date), label: "Lease expiration date", helper_method: :human_readable_date
    config.add_index_field solr_name("degree", :stored_searchable), label: "Degree"
    config.add_index_field solr_name("department", :stored_searchable), label: "Unit (Department)"
    config.add_index_field solr_name("award", :stored_searchable), label: "Award"

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name("title", :stored_searchable)
    config.add_show_field solr_name("description", :stored_searchable)
    config.add_show_field solr_name("keyword", :stored_searchable)
    config.add_show_field solr_name("creator", :stored_searchable)
    config.add_show_field solr_name("contributor", :stored_searchable)
    config.add_show_field solr_name("publisher", :stored_searchable)
    config.add_show_field solr_name("date_created", :stored_searchable)
    config.add_show_field solr_name("degree", :stored_searchable), label: "Degree"
    config.add_show_field solr_name("department", :stored_searchable), label: "Unit (Department)"
    config.add_show_field solr_name("format", :stored_searchable)
    config.add_show_field solr_name("identifier", :stored_searchable)
    config.add_show_field solr_name("subject", :stored_searchable)
    config.add_show_field solr_name("based_near_label", :stored_searchable)
    config.add_show_field solr_name("language", :stored_searchable)
    config.add_show_field solr_name("date_uploaded", :stored_searchable)
    config.add_show_field solr_name("date_modified", :stored_searchable)
    config.add_show_field solr_name("rights_statement", :stored_searchable)
    config.add_show_field solr_name("license", :stored_searchable)
    config.add_show_field solr_name("resource_type", :stored_searchable), label: "Resource Type"
    config.add_show_field solr_name("award", :stored_searchable), label: "Award"
    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      all_names = config.show_fields.values.map(&:field).join(" ")
      title_name = solr_name("title", :stored_searchable)
      field.solr_parameters = {
        qf: "#{all_names} file_format_tesim all_text_timv",
        pf: title_name.to_s
      }
      field.include_in_advanced_search = false
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    # creator, title, description, publisher, date_created,
    # subject, language, resource_type, format, identifier, based_near,

    config.add_search_field('all_metadata_fields', label: 'All Fields (no full text)') do |field|
      solr_name = "all_metadata_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('title') do |field|
      solr_name = solr_name("title", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('creator') do |field|
      solr_name = solr_name("creator", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('advisor') do |field|
      solr_name = solr_name("advisor", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('contributor') do |field|
      solr_name = solr_name("contributor", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('resource_type') do |field|
      solr_name = solr_name("resource_type", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('description') do |field|
      field.label = "Abstract or Summary"
      solr_name = solr_name("description", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('subject') do |field|
      solr_name = solr_name("subject", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('keyword') do |field|
      solr_name = solr_name("keyword", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('publisher') do |field|
      solr_name = solr_name("publisher", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('identifier') do |field|
      solr_name = solr_name("identifier", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('date_created') do |field|
      solr_name = solr_name("date_created", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('language') do |field|
      solr_name = solr_name("language", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end

    config.add_search_field('format') do |field|
      solr_name = solr_name("format", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end

    config.add_search_field('based_near') do |field|
      field.label = "Location"
      solr_name = solr_name("based_near_label", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end

    config.add_search_field('depositor') do |field|
      solr_name = solr_name("depositor", :symbol)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end

    config.add_search_field('rights_statement') do |field|
      solr_name = solr_name("rights_statement", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end

    config.add_search_field('license') do |field|
      solr_name = solr_name("license", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "score desc, #{uploaded_field} desc", label: "relevance"
    config.add_sort_field "#{uploaded_field} desc", label: "date uploaded \u25BC"
    config.add_sort_field "#{uploaded_field} asc", label: "date uploaded \u25B2"
    config.add_sort_field "#{modified_field} desc", label: "date modified \u25BC"
    config.add_sort_field "#{modified_field} asc", label: "date modified \u25B2"

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Add Blacklight OAI provider Configuration for Primo
    config.oai = {
        provider: {
            repository_name: 'digitalwpi',
            repository_url: Rails.application.config.application_root_url.to_s + '/catalog/oai',
            record_prefix: 'oai:digitalwpi',
            admin_email: 'zchen12@wpi.edu',
            sample_id: '109660'
        },
        document: {
            limit: 25,            # number of records returned with each request, default: 15
            set_fields: [        # ability to define ListSets, optional, default: nil
                { label: 'identifier', solr_field: 'identifier_tesim' },
                { label: 'title', solr_field: 'title_tesim' },
                { label: 'creator', solr_field: 'creator_tesim' },
                { label: 'date', solr_field: 'date_created_tesim' },
                { label: 'description', solr_field: 'description_tesim' },
                { label: 'subject', solr_field: 'subject_tesim' },
                { label: 'contributor', solr_field: 'contributor_tesim' },
                { label: 'format', solr_field: 'file_format_tesim' },
                { label: 'language', solr_field: 'language_tesim' },
                { label: 'publisher', solr_field: 'publisher_tesim' },
                { label: 'rights', solr_field: 'rights_statement_tesim' },
                { label: 'source', solr_field: 'source_tesim' },
                { label: 'type', solr_field: 'resource_type_tesim' }
            ]
        }
    }

    config.advanced_search[:form_solr_parameters] ||= {
      "facet.limit" => "-1",
      "facet.sort" => "index"
    }

  end

  # disable the bookmark control from displaying in gallery view
  # Hyrax doesn't show any of the default controls on the list view, so
  # this method is not called in that context.
  def render_bookmarks_control?
    true
  end

  def export_as_csv
    send_data search_documents, type: 'text/csv', disposition: 'inline', filename: "search_result.csv"
  end

  def search_documents
    blacklight_config.max_per_page = 5000
    page = 1
    per_page = 5000
    total_pages = Float::INFINITY 
    csv_string = ''
    header_fields = ['id', 'has_model_ssim', 'title_tesim', 'creator_tesim', 'identifier_tesim', 'description_tesim', 'contributor_tesim', 'advisor_tesim', 'committee_tesim', 'keyword_tesim', 'language_tesim', 'publisher_tesim', 'subject_tesim', 'resource_type_tesim', 'degree_tesim', 'department_tesim', 'year_tesim', 'rights_statement_tesim', 'license_tesim', 'sponsor_tesim', 'orcid_tesim']

    csv_string = CSV.generate(headers: true) do |csv|
      # Add header to csv
      csv << header_fields

      while page <= total_pages
        params[:page] = page
        params[:per_page] = per_page
        (@response, @document_list) = search_results(params)
        # Iterate over the array of hashes to add data rows
        @document_list.each do |list|
          data = list._source
          row = []
          header_fields.each do |fields|
            if data[fields].present? && data[fields].is_a?(Array)
              row << data[fields].join(",")
            else
              row << (data[fields] || '')
            end
          end
          csv << row
        end

        total_pages = @response.total_pages if page == 1
        page +=1
      end
    end

    csv_string
  end
end
