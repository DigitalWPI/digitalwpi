class ImportObjectService
  def initialize(file_path, base_dir, model)
    @file_path = file_path
    @base_dir = base_dir
    @model = model
    @work_ids = get_work_id_mappings
    @collection_ids = get_collection_id_mappings
    @fileset_ids = get_fileset_id_mappings
    @metadata = parse_metadata_file(@file_path)
  end

  def call
    process_metadata
  end

  private

  def process_metadata
    if @model == "StudentWork"
      process_student_work_metadata
    elsif @model == "GenericWork"
      process_generic_work_metadata
    elsif @model == "Etd"
      process_etd_metadata
    end
  end

  def process_student_work_metadata
    Rails.logger.info("Step 1/4 - Importing dataset #{@metadata["id"]}")
    new_id =  @work_ids.fetch(@metadata["id"], nil)
    student_work = StudentWork.find_by(id: new_id) if new_id.present?
    student_work ||= StudentWork.new(id: new_id || nil)
    student_work = assign_common_metadata(student_work)
    student_work = assign_additional_student_work_metadata(student_work)
  end

  def process_generic_work_metadata
    Rails.logger.info("Step 1/4 - Importing dataset #{@metadata["id"]}")
    new_id =  @work_ids.fetch(@metadata["id"], nil)
    generic_work = GenericWork.find_by(id: new_id) if new_id.present?
    generic_work ||= GenericWork.new(id: new_id || nil)
    generic_work = assign_common_metadata(generic_work)
    generic_work = assign_additional_generic_metadata(generic_work)
  end

  def process_etd_metadata
    Rails.logger.info("Step 1/4 - Importing dataset #{@metadata["id"]}")
    new_id =  @work_ids.fetch(@metadata["id"], nil)
    etd = Etd.find_by(id: new_id) if new_id.present?
    etd ||= Etd.new(id: new_id || nil)
    etd = assign_common_metadata(etd)
    etd = assign_additional_etd_metadata(etd)
  end

  def assign_common_metadata(work)
    work.admin_set_id = AdminSetHelper.find_by(title: @metadata["admin_set_tesim"]).id if @metadata["admin_set_tesim"].present?
    work.member_of_collection_ids = get_member_collection_ids(check_exists: true)
    work.member_ids = get_member_work_ids
    work.title = @metadata["title_tesim"]
    work.creator = @metadata["creator_tesim"]
    work.rights_statement = @metadata["rights_statement_tesim"]
    work.contributor = @metadata["contributor_tesim"]
    work.description = @metadata["description_tesim"]
    work.abstract = @metadata["abstract_tesim"]
    work.keyword = @metadata["keyword_tesim"]
    work.license = @metadata["license_tesim"]
    work.access_right = @metadata["access_right_tesim"]
    work.rights_notes = @metadata["rights_notes_tesim"]
    work.publisher = @metadata["publisher_tesim"]
    work.date_created = @metadata["date_created_tesim"]
    work.subject = @metadata["subject_tesim"]
    work.language = @metadata["language_tesim"]
    work.identifier = @metadata["identifier_tesim"]
    work.based_near = @metadata["based_near_tesim"]
    work.related_url = @metadata["related_url_tesim"]
    work.source = @metadata["source_tesim"]
    work.resource_type = @metadata["resource_type_tesim"]

    work.award = @metadata["award_tesim"]
    work.includes = @metadata["includes_tesim"]
    work.alternate_title = @metadata["alternate_title_tesim"]
    work.year = @metadata["year_tesim"]
    work.school = @metadata["school_tesim"]
    work.editorial_note = @metadata["editorial_note_tesim"]

    work
  end

  def assign_additional_generic_metadata(work)
    work.digitization_date = @metadata["digitization_date_tesim"]
    work.series = @metadata["series_tesim"]
    work.event = @metadata["event_tesim"]
    work.extent = @metadata["extent_tesim"]
    work.citation = @metadata["citation_tesim"]
    work
  end

  def assign_additional_etd_metadata(work)
    work.degree = @metadata["degree_tesim"]
    work.department = @metadata["department_tesim"]
    work.orcid = @metadata["orcid_tesim"]
    work.committee = @metadata["committee_tesim"]
    work.defense_date = @metadata["defense_date_tesim"]
    work = common_etd_and_student_work_metadata(work)

    work
  end

  def assign_additional_student_work_metadata(work)
    work.major = @metadata["major_tesim"]
    work.note = @metadata["note_tesim"]
    work = common_etd_and_student_work_metadata(work)

    work
  end

  def common_etd_and_student_work_metadata(work)
    work.center = @metadata["center_tesim"]
    work.editorial_note = @metadata["editorial_note_tesim"]
    work.advisor = @metadata["advisor_tesim"]
    work.advisor = @metadata["advisor_tesim"]
    work.institute = @metadata["institute_tesim"]
    work.sdg = @metadata["sdg_tesim"]
    
    work
  end

  def process_embargo(work)
    return unless @metadata["embargo_release_date_dtsi"]

    embargo_release_date = DateTime.parse(@metadata["embargo_release_date_dtsi"])
    
    return unless embargo_release_date.present?

    embargo = Hyrax.query_service.find_by(id: work.embargo_id) if work.embargo_id.present?
    embargo = Hyrax::Embargo.new
    embargo.embargo_release_date = embargo_release_date
    embargo.visibility_during_embargo = @metadata["visibility_during_embargo_ssim"]
    embargo.visibility_after_embargo = @metadata["visibility_after_embargo_ssim"]
    embargo.embargo_history = embargo.embargo_history + @metadata["embargo_history_ssim"]

    embargo = Hyrax.persister.save(resource: embargo)
    work.embargo_id = embargo.id

    work
  end
end