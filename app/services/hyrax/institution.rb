# frozen_string_literal: true
require Hyrax::Engine.root.join('app/services/hyrax/institution.rb')
module Hyrax
  class Institution
    def self.name
      I18n.t('hyrax.institution_name')
    end

    def self.name_full
      I18n.t('hyrax.institution_name_full', default: name)
    end

    def self.address
      I18n.t('hyrax.institution_address')
    end
  end
end
