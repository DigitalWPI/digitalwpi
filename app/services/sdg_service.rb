module SdgService
	mattr_accessor :authority
	self.authority = Qa::Authorities::Local.subauthority_for('sdg')
	
	def self.select_all_options
		authority.all.map do |element|
			[element[:label], element[:id]]
		end
	end
	
	def self.label(id)
		old_sdg = [
			"1 - No Poverty",
			"2 - Zero Hunger",
			"3 - Good Health and Well-being",
			"4 - Quality Education",
			"5 - Gender Equality",
			"6 - Clean Water and Sanitation",
			"7 - Affordable and Clean Energy",
			"8 - Decent Work and Economic Growth",
			"9 - Industry, Innovation and Infrastructure"
		]

		if old_sdg.include?(id)
			id
		else
			authority.find(id).fetch('term')
		end
	end
end
