# frozen_string_literal: true

module Hyrax
  module SolrDocument
    module Export

      RIS_LINE_END = "\r\n"
      RIS_END_RECORD = "ER  -#{RIS_LINE_END}"

      def export_as_ris
        lines = []
        # TY needs to be first
        lines << "TY  - #{ris_type}"

        ris_format.each_pair do |tag, value|
          Array(value).each do |v|
            lines << "#{tag}  - #{v}"
          end
        end

        lines << RIS_END_RECORD
        lines.join(RIS_LINE_END)
      end

      def ris_type
        if human_readable_type == "Etd"
          "THES"
        elsif human_readable_type == "Student Work"
          "RPRT"
        else
          "GEN"
        end
      end

      def ris_format
       {
          "A1" => creator,
          "A2" => contributor,
          "AB" => description,
          "CY" => based_near_label,
          "DA" => date_created[0].gsub('-','/'),
          "DB" => I18n.t('hyrax.product_name'),
          "DP" => Institution.name_full,
          "ID" => identifier,
          "KW" => keyword,
          "L1" => first_file,
          "L3" => other_files,
          "LA" => language,
          "LK" => home_url,
          "PB" => publisher,
          "PY" => year,
          "T1" => title,
          "T2" => alternate_title,
          "UR" => persistent_url
        }
      end

      def ris_filename
        "#{id}.ris"
      end

      def first_file
        to_url(representative_id)
      end

      def other_files
        others = []
        response['response']['docs'][0]['file_set_ids_ssim'].each do |set_id|
          unless set_id == representative_id
            others << to_url(set_id)
          end
        end
        others
      end

      def home_url
        'https://' + ENV["SERVERNAME"] + '/'
      end

      def to_url(rep_id)
        home_url + 'show/' + rep_id
      end

      # MIME: 'application/x-endnote-refer'
      def export_as_endnote
        text = []
        text << "%0 #{human_readable_type}"
        end_note_format.each do |endnote_key, mapping|
          if mapping.is_a? String
            values = [mapping]
          else
            values = send(mapping[0]) if respond_to? mapping[0]
            values = mapping[1].call(values) if mapping.length == 2
            values = Array.wrap(values)
          end
          next if values.blank? || values.first.nil?
          spaced_values = values.join("; ")
          text << "#{endnote_key} #{spaced_values}"
        end
        text.join("\n")
      end

      # Name of the downloaded endnote file
      # Override this if you want to use a different name
      def endnote_filename
        "#{id}.endnote"
      end

      def persistent_url
        "#{Hyrax.config.persistent_hostpath}#{id}"
      end

      def end_note_format
        {
          '%T' => [:title],
          # '%Q' => [:title, ->(x) { x.drop(1) }], # subtitles
          '%A' => [:creator],
          '%C' => [:publication_place],
          '%D' => [:date_created],
          '%8' => [:date_uploaded],
          '%E' => [:contributor],
          '%I' => [:publisher],
          '%J' => [:series_title],
          '%@' => [:isbn],
          '%U' => [:related_url],
          '%7' => [:edition_statement],
          '%R' => [:persistent_url],
          '%X' => [:description],
          '%G' => [:language],
          '%[' => [:date_modified],
          '%9' => [:resource_type],
          '%~' => I18n.t('hyrax.product_name'),
          '%W' => Institution.name
        }
      end

    end
  end
end
