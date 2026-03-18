module IndexerHelper
  def all_metadata_values
    values = [
      object.title,
      object.description,
      object.keyword,
      object.creator,
      object.contributor,
      object.publisher,
      # object.format,
      object.identifier,
      object.subject,
      # object.based_near_label,
      object.language,
      object.rights_statement,
      object.license,
      object.resource_type,
      object.alternate_title,
      object.award,
      object.year
    ]
    values.append(object.advisor) if object.class.method_defined?(:advisor)
    values.append(object.sponsor) if object.class.method_defined?(:sponsor)
    values.append(object.center) if object.class.method_defined?(:center)
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
        puts("%Y#{separator}%m#{separator}%d")
        begin
          dt = Date.strptime(date_str, "%Y#{separator}%m#{separator}%d")
        rescue
          dt = Date.strptime(date_str, "%Y#{separator}%d#{separator}%m")
        end
      elsif date_str =~ /^\d{4}-\d{2}$/
        puts("%Y#{separator}%m")
        dt = Date.strptime(date_str, "%Y#{separator}%m")
      elsif date_str =~ /^\d{4}[- \/]\d{4}$/
        puts("%Y#{separator}%Y")
        year = date_str.split(separator)[0]
        dt = Date.strptime(year, "%Y")
      elsif date_str =~ /^\d{2}[- \/]\d{2}[- \/]\d{4}$/
        puts("%d-%m-%Y")
        begin
          dt = Date.strptime(date_str, "%d#{separator}%m#{separator}%Y")
        rescue
          dt = Date.strptime(date_str, "%m#{separator}%d#{separator}%Y")
        end
      elsif date_str =~ /^\d{2}[- \/]\d{4}$/
        puts("%m-%Y")
        dt = Date.strptime(date_str, "%m-%Y")
      elsif date_str =~ /^\d{4}$/
        puts "%Y"
        dt = Date.strptime(date_str, "%Y")
      elsif date_str =~ /^[A-Za-z][A-Za-z][A-Za-z][- \/]\d{4}$/
        puts "Mon %Y"
        dt = Date.strptime(date_str, "%b#{separator}%Y")
      else
        puts "Month#{separator}%Y"
        dt = Date.strptime(date_str, "%B#{separator}%Y")
      end
    rescue
      dt = nil
    end
    dt
  end
end