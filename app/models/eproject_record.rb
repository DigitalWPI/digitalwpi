class EprojectRecord < ApplicationRecord
    def self.get_new_works(client_id,client_secret,oath_token_url,protected_url)
        #todo
        #get token using oath
        # do a get of something?
        # loop through responses
        #   ingest works
        #   create EprojectRecord associating work and eproject obj.
        #   update eproj each time work ingested
        #   update eproj each tiem work failed
    end
    def work
        begin
            return ActiveFedora::Base.find(self.work_id)
        rescue
            return nil
        end
    end
    def work=(work)
        if work.kind_of? ActiveFedora::Base
            self.work_id = work.id 
        else
            raise "Work must be a Hyrax Worktype (ActiveFedora::Base) object"
        end
    end
end
