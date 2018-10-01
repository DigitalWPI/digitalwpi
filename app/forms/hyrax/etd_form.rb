# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated form for Etd
  class EtdForm < Hyrax::Forms::WorkForm
    self.model_class = ::Etd
    self.terms = [:title, :creator, :contributor, :description,
                  :degree, :department,
                  :keyword, :license, :rights_statement, :publisher, :date_created,
                  :subject, :language, :identifier, :based_near, :related_url,
                  :resource_type,
                  :representative_id, :thumbnail_id, :rendering_ids, :files,
                  :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
                  :visibility_during_lease, :lease_expiration_date, :visibility_after_lease,
                  :visibility, :ordered_member_ids, :source, :in_works_ids,
                  :member_of_collection_ids, :admin_set_id]
  end
end
