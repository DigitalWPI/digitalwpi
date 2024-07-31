# make sure date format is yyyy-mm--dd and the result count is integer
if ENV.fetch('HYRAX_ANALYTICS', 'false').downcase == 'true'
  Rails.configuration.to_prepare do
    Hyrax::Analytics::Matomo.module_eval do
      class_methods do
        # Format Data Range "2021-01-01,2021-01-31"
        def default_date_range
          "#{Hyrax.config.analytics_start_date},#{Time.zone.today.strftime("%Y-%m-%d")}"
        end
  
        def api_params(method, period, date, additional_params = {})
          date = date.split(',').map{ |d| d.to_date.strftime("%Y-%m-%d")}.join(',')
          params = {
            module: "API",
            idSite: config.site_id,
            method: method,
            period: period,
            date: date,
            format: "JSON",
            token_auth: config.auth_token
          }
          params.merge!(additional_params)
          get(params)
        end
      end
    end

    Hyrax::Analytics::Results.class_eval do
      def initialize(results)
        @results ||= results
        @results = @results.map{|result| [result[0], result[1].to_i]} if @results.is_a?(Array)
      end
    end

  end
end

