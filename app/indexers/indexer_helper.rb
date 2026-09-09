module IndexerHelper
  def all_metadata_values
    values = [
      resource.title,
      resource.description,
      resource.keyword,
      resource.creator,
      resource.contributor,
      resource.publisher,
      # resource.format,
      resource.identifier,
      resource.subject,
      # resource.based_near_label,
      resource.language,
      resource.rights_statement,
      resource.license,
      resource.resource_type,
      resource.alternate_title,
      resource.award,
      resource.year
    ]
    values.append(resource.advisor) if resource.class.method_defined?(:advisor)
    values.append(resource.sponsor) if resource.class.method_defined?(:sponsor)
    values.append(resource.center) if resource.class.method_defined?(:center)
    # values.flatten!
    # values.reject(&:blank?)
    flattened_values = []
    values.each do |val|
      flattened_values += Array(val).reject(&:blank?)
    end
    flattened_values
  end

  def parse_date(date_str)
    if date_str.include?('-')
      separator = '-'
    elsif date_str.include?(' ')
      separator = ' '
    elsif date_str.include?('/')
      separator = '/'
    end
    begin
      if date_str =~ /^\d{4}[- \/]\d{2}[- \/]\d{2}$/
        begin
          dt = Date.strptime(date_str, "%Y#{separator}%m#{separator}%d")
        rescue
          dt = Date.strptime(date_str, "%Y#{separator}%d#{separator}%m")
        end
      elsif date_str =~ /^\d{4}-\d{2}$/
        dt = Date.strptime(date_str, "%Y#{separator}%m")
      elsif date_str =~ /^\d{4}[- \/]\d{4}$/
        year = date_str.split(separator)[0]
        dt = Date.strptime(year, "%Y")
      elsif date_str =~ /^\d{2}[- \/]\d{2}[- \/]\d{4}$/
        begin
          dt = Date.strptime(date_str, "%d#{separator}%m#{separator}%Y")
        rescue
          dt = Date.strptime(date_str, "%m#{separator}%d#{separator}%Y")
        end
      elsif date_str =~ /^\d{2}[- \/]\d{4}$/
        dt = Date.strptime(date_str, "%m-%Y")
      elsif date_str =~ /^\d{4}$/
        dt = Date.strptime(date_str, "%Y")
      elsif date_str =~ /^[A-Za-z][A-Za-z][A-Za-z][- \/]\d{4}$/
        dt = Date.strptime(date_str, "%b#{separator}%Y")
      else
        dt = Date.strptime(date_str, "%B#{separator}%Y")
      end
    rescue
      dt = nil
    end
    dt
  end
end