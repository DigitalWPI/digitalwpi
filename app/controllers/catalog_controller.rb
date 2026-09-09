# frozen_string_literal: true
require 'csv'
class CatalogController < ApplicationController

  include BlacklightRangeLimit::ControllerOverride
  include BlacklightAdvancedSearch::Controller
  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior
  include BlacklightOaiProvider::Controller
  include DownloadHelper
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

  def self.title_sort
    "title_ansort"
  end

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    config.advanced_search[:enabled] = true
    config.advanced_search[:form_solr_paramters] = {}
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'

    # config.view.gallery.partials = [:index_header, :index]
    # config.view.masonry.partials = [:index]
    # config.view.slideshow.partials = [:index]

    # Show gallery view
    config.view.gallery(document_component: Blacklight::Gallery::DocumentComponent, icon: Blacklight::Gallery::Icons::GalleryComponent)
    config.view.masonry(document_component: Blacklight::Gallery::DocumentComponent, icon: Blacklight::Gallery::Icons::MasonryComponent)
    config.view.slideshow(document_component: Blacklight::Gallery::SlideshowComponent, icon: Blacklight::Gallery::Icons::SlideshowComponent)

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials ||= []
    config.show.partials.insert(1, :openseadragon)
    config.search_builder_class = Hyrax::CatalogSearchBuilder

    # Because too many times on Samvera tech people raise a problem regarding a failed query to SOLR.
    # Often, it's because they inadvertently exceeded the character limit of a GET request.
    config.http_method = Hyrax.config.solr_default_method

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: "search",
      rows: 10,
      qf: "title_tesim description_tesim creator_tesim keyword_tesim"
    }

    # solr field configuration for document/show views
    config.index.title_field = "title_tesim"
    config.index.display_type_field = "has_model_ssim"
    config.index.thumbnail_field = 'thumbnail_path_ss'

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)
    config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)
    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    # config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type", limit: 5
    config.add_facet_field "member_of_collection_ids_ssim", label: 'Collections', sort: 'count', collapse: false, helper_method: :collection_title_by_id, limit: 5
    #config.add_facet_field solr_name("member_of_collections", :symbol), limit: 5, label: 'Collections', collapse: false
    #config.add_facet_field solr_name("year", :facetable), label: "Year", sort: 'index desc', limit: 5
    config.add_facet_field  "year_sim", label: "Year", range: {
     num_segments: 6,
     assumed_boundaries: [1840, Time.now.year+2],
     segments: true,
     maxlength: 10
    }, include_in_advanced_search: false
    config.add_facet_field "creator_sim", sort: 'index', index_range: 'A'..'Z', limit: 5, include_in_advanced_search: false
    config.add_facet_field "advisor_sim", label: "Advisor", sort: 'index', index_range: 'A'..'Z', limit: 5
    config.add_facet_field "contributor_sim", label: "Contributor", sort: 'index', index_range: 'A'..'Z', limit: 5, include_in_advanced_search: false
    config.add_facet_field "center_sim", label: "Project Center", sort: 'index', index_range: 'A'..'Z', limit: 5
    config.add_facet_field "major_sim", label: "Major", sort: 'index', index_range: 'A'..'Z', limit: 5
    config.add_facet_field "department_sim", label: "Unit (Department)", sort: 'index', index_range: 'A'..'Z', limit: 5
    config.add_facet_field "publisher_sim", limit: 5, include_in_advanced_search: false
    config.add_facet_field "subject_sim", sort: 'index', index_range: 'A'..'Z', limit: 5, include_in_advanced_search: false
    config.add_facet_field "sdg_sim", label: "UN SDG", limit: 17, sort: 'index', helper_method: :sdg_facet_display
    config.add_facet_field "resource_type_sim", label: "Resource Type", limit: 5
    config.add_facet_field "license_sim", label: "License", limit: 5
    config.add_facet_field "award_sim", label: "Award", limit: 5
    # Removing sponsor facet, as the values are not controlled -
    # https://github.com/antleaf/wpi-repository-project/issues/69#issuecomment-1746994760
    # config.add_facet_field "sponsor_sim", label: "Sponsor", sort: 'index', index_range: 'A'..'Z', limit: 5
    #config.add_facet_field "language_sim", limit: 5


    # The generic_type isn't displayed on the facet list
    # It's used to give a label to the filter that comes from the user profile
    config.add_facet_field "generic_type_sim", if: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field "title_tesim", label: "Title", itemprop: 'name', if: false
    # config.add_index_field "description_tesim", itemprop: 'description', helper_method: :iconify_auto_link
    config.add_index_field "keyword_tesim", itemprop: 'keywords', link_to_search: "keyword_sim"
    # config.add_index_field "subject_tesim", itemprop: 'about', link_to_search: "subject_sim"
    config.add_index_field "creator_tesim", itemprop: 'creator', link_to_search: "creator_sim"
    # config.add_index_field "contributor_tesim", itemprop: 'contributor', link_to_search: "contributor_sim"
    config.add_index_field "advisor_tesim", label: "Advisor", itemprop: 'advisor', link_to_search: "advisor_sim"
    # config.add_index_field "proxy_depositor_tesim", label: "Depositor", helper_method: :link_to_profile
    # config.add_index_field "depositor_tesim", label: "Owner", helper_method: :link_to_profile
    config.add_index_field "publisher_tesim", itemprop: 'publisher', link_to_search: "publisher_sim"
    # config.add_index_field "based_near_label_tesim", itemprop: 'contentLocation', link_to_search: "based_near_label_sim"
    # config.add_index_field "language_tesim", itemprop: 'inLanguage', link_to_search: "language_sim"
    # config.add_index_field "date_uploaded_tesim", itemprop: 'datePublished', helper_method: :human_readable_date
    # config.add_index_field "date_modified_tesim", itemprop: 'dateModified', helper_method: :human_readable_date
    config.add_index_field "date_created_tesim", itemprop: 'dateCreated', include_in_advanced_search: false
    # config.add_index_field "rights_statement_tesim", helper_method: :rights_statement_links
    # config.add_index_field "license_tesim", helper_method: :license_links
    config.add_index_field "resource_type_tesim", label: "Resource Type", link_to_search: "resource_type_sim"
    # config.add_index_field "file_format_tesim", link_to_search: "file_format_sim"
    # config.add_index_field "identifier_tesim", helper_method: :index_field_link, field_name: 'identifier'
    # config.add_index_field "embargo_release_date_tesim", label: "Embargo release date", helper_method: :human_readable_date
    # config.add_index_field "lease_expiration_date_tesim", label: "Lease expiration date", helper_method: :human_readable_date
    config.add_index_field "degree_tesim", label: "Degree"
    config.add_index_field "department_tesim", label: "Unit (Department)"
    config.add_index_field "award_tesim", label: "Award"

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field "title_tesim"
    config.add_show_field "description_tesim"
    config.add_show_field "keyword_tesim"
    config.add_show_field "creator_tesim"
    config.add_show_field "contributor_tesim"
    config.add_show_field "publisher_tesim"
    config.add_show_field "date_created_tesim"
    config.add_show_field "degree_tesim", label: "Degree"
    config.add_show_field "department_tesim", label: "Unit (Department)"
    config.add_show_field "format_tesim"
    config.add_show_field "identifier_tesim"
    config.add_show_field "subject_tesim"
    config.add_show_field "based_near_label_tesim"
    config.add_show_field "language_tesim"
    config.add_show_field "date_uploaded_tesim"
    config.add_show_field "date_modified_tesim"
    config.add_show_field "rights_statement_tesim"
    config.add_show_field "license_tesim"
    config.add_show_field "resource_type_tesim", label: "Resource Type"
    config.add_show_field "award_tesim", label: "Award"
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
      title_name = "title_tesim"
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
      solr_name = "title_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('creator') do |field|
      solr_name = "creator_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('advisor') do |field|
      solr_name = "advisor_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('contributor') do |field|
      solr_name = "contributor_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('sponsor') do |field|
      solr_name = "sponsor_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('resource_type') do |field|
      solr_name = "resource_type_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('description') do |field|
      field.label = "Abstract or Summary"
      solr_name = "description_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('subject') do |field|
      solr_name = "subject_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('keyword') do |field|
      solr_name = "keyword_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('publisher') do |field|
      solr_name = "publisher_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('identifier') do |field|
      solr_name = "identifier_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('date_created') do |field|
      solr_name = "date_created_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('language') do |field|
      solr_name = "language_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end

    config.add_search_field('format') do |field|
      solr_name = "format_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end

    config.add_search_field('based_near') do |field|
      field.label = "Location"
      solr_name = "based_near_label_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end

    config.add_search_field('depositor') do |field|
      solr_name = "depositor_ssim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end

    config.add_search_field('rights_statement') do |field|
      solr_name = "rights_statement_tesim"
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
      field.include_in_advanced_search = false
    end

    config.add_search_field('license') do |field|
      solr_name = "license_tesim"
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
    config.add_sort_field "#{created_field} desc", label: "date created \u25BC"
    config.add_sort_field "#{created_field} asc", label: "date created \u25B2"
    config.add_sort_field "#{title_sort} desc", label: "Title \u25BC"
    config.add_sort_field "#{title_sort} asc", label: "Title \u25B2"
    config.add_sort_field "score desc, #{created_field} desc", label: "relevance"

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
    #send_data search_documents, type: 'text/csv', disposition: 'inline', filename: "search_result.csv"
    if user_signed_in?
      send_data search_documents, type: 'text/csv', disposition: 'inline', filename: "search_result.csv"
    else
      redirect_to root_path
    end
  end

  private

  # @note Overrides Blacklight::SearchContext to NOT save searches into the current session. This prevents searches
  # from being written to the Search table, and also disables the feature to allow users to save their searches for
  # future use.
  def current_search_session
    session
  end

end
