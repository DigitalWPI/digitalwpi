require 'csv'
namespace :wpi do
  desc "Import Google Analytics 3 stats into WorkViewStat and FileViewStat models"
  # This task reads a CSV file containing Google Analytics data and updates the WorkViewStat and FileViewStat models accordingly.
  task :import_ga3_stats, [:csv_file_path] => :environment do |task, args|

    file_path = args[:csv_file_path]

    abort "Please provide a CSV file path" unless file_path
    abort "Provided wrong file path" unless File.exist?(file_path)

    work_prefixes = Hyrax.config.curation_concerns.map{|model_name| model_name.to_s.underscore.pluralize}
    work_prefixes += ['works']
    fileset_prefix = 'file_sets'

    CSV.foreach(file_path, headers: true) do |row|
      path = row['ga:pagePath']
      next unless path
      date = Date.strptime(row['ga:date'], '%Y%m%d').to_time.beginning_of_day

      if work_prefixes.any? { |prefix| path.include?("/#{prefix}/") }
        prefix = work_prefixes.find { |p| path.include?("/#{p}/") }
        id = extract_id(path, prefix)
        if id
          work_view_stat = WorkViewStat.find_or_initialize_by(date: date, work_id: id)
          if work_view_stat.work_views.to_i < row['ga:pageviews'].to_i
            work_view_stat.work_views = row['ga:pageviews'].to_i
          end
          work_view_stat.save!
        end
      elsif path.include?("/#{fileset_prefix}/")
        id = extract_id(path, fileset_prefix)
        if id
          file_view_stat = FileViewStat.find_or_initialize_by(date: date, file_id: id)
          if file_view_stat.views.to_i < row['ga:pageviews'].to_i
            file_view_stat.views = row['ga:pageviews'].to_i
          end
          file_view_stat.save!
        end
      end
    end

    puts "Import completed successfully."
  rescue StandardError => e
    puts "An error occurred during import: #{e.message}"
  end

  # Helper method to extract the ID from the path based on the prefix
  def extract_id(path, prefix)
    match = path.match(%r{/#{prefix}/([a-zA-Z0-9]{9})})
    match[1] if match
  end
end