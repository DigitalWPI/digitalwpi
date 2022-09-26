
module SdgService
	mattr_accessor :authority
	self.authority = Qa::Authorities::Local.subauthority_for('sdg')
	
	def self.select_all_options
		authority.all.map do |element|
			[element[:label], element[:id]]
		end
	end
	
	def self.label(id)
		if authority.find(id).present?
			authority.find(id).fetch('term')
		else
			id
		end
	end
end
