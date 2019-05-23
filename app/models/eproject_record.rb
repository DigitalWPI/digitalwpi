class EprojectRecord < ApplicationRecord
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
