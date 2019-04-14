require 'piwik'

module Hyrax
  module Analytics
  	class Matomo
  	  REQUIRED_KEYS = %w[matomo_site_id matomo_token matomo_url].freeze
  	  class << self
        attr_reader :config
      end
      def self.config
  	    @config ||= Config.load_from_yaml
	    end
	    # private_class_method :config
	    def self.valid?
	    	self.config.valid?
	    end
	    def self.matomo_site_id
	    	self.config.matomo_site_id
	    end
	    def self.matomo_token
	    	self.config.matomo_token
	    end
	    def self.matomo_url
	    	self.config.matomo_url
	    end
	    class Config
	      def self.load_from_yaml
	        filename = Rails.root.join('config', 'analytics.yml')
	        yaml = YAML.safe_load(ERB.new(File.read(filename)).result)
	        unless yaml
	          Rails.logger.error("Unable to fetch any keys from #{filename}.")
	          return new({})
	        end
	        new yaml.fetch('analytics')
	      end

	      def initialize(config)
	        @config = config
	      end

	      # @return [Boolean] are all the required values present?
	      def valid?
	        config_keys = @config.keys
	        REQUIRED_KEYS.all? do |required|
	          config_keys.include?(required) && @config[required].present?
	        end
	      end

	      REQUIRED_KEYS.each do |key|
	        class_eval %{ def #{key};  @config.fetch('#{key}'); end }
	      end
	    end
      def self.unique_visitors(start_date)
        Piwik::VisitsSummary.getUniqueVisitors(idSite: matomo_site_id, period: :range, date: "#{start_date},#{Time.zone.today}")
        # Manipulate `result` to an agreed upon data structure
      end
    end
  end
end