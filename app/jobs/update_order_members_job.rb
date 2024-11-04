class UpdateOrderMembersJob < ApplicationJob 
  queue_as :default

  def perform(curation_concern_type, document_id)
    curation_concern = curation_concern_type.constantize.find(document_id)

    if curation_concern.member_ids.count > curation_concern.ordered_member_ids.count
      missing_ids = curation_concern.member_ids - curation_concern.ordered_member_ids
      missing_ids.each do |doc_id|
        missing_member  = ActiveFedora::Base.find(doc_id)
        curation_concern.ordered_members << missing_member
        curation_concern.save
      rescue ActiveFedora::ObjectNotFoundError
        Rails.logger.error("Unable to fetch document with id: #{doc_id}.")
      end 
    end
  end
end 